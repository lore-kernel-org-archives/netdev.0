From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Receive Side Support (RSS) - Adding support into the kernel
Date: Fri, 21 Nov 2008 18:55:46 +0000
Message-ID: <20081121185544.GB32518@solarflare.com>
References: <d41814900811210948p2fb2059epbd381a8105ab8959@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andrew Brampton <brampton@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:42182 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756669AbYKUSzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 13:55:49 -0500
Content-Disposition: inline
In-Reply-To: <d41814900811210948p2fb2059epbd381a8105ab8959@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Brampton wrote:
> Hi,
> Recently I've been interested in receive side support (RSS)[1], the

RSS stands for Receive-Side _Scaling_.

[...]
> There are three RSS settings which can be configured
> 1) Which fields of the packet get hashed.

There are ethtool {get,set}_rxhash() methods for this already.  So far
only niu implements them.

> 2) The key used by the hashing algorithm
> 3) The indirection table, which is used to map a 7bit hash value to a
> particular core.
[...]
> I think creating a userland daemon is the best approach, as such here
> are my suggestions for changes to be made to the kernel.
> 
> I'm suggesting that firstly each driver exports a set of functions
> which allow the RSS settings to be changed. This can be done by adding
> another field to the net_device struct, which would be a struct of
> function pointers, such as rss_set_key, rss_get_get, rss_set_hash,
> rss_get_hash, etc.
[...]

My understanding is that Windows drivers are required to support changing
the hash key dynamically but in practice Windows does not do so.  This
suggests that there is little need to do so, and that it could be done
through ethtool without adding unacceptable overhead.

You also need to consider how drivers should communicate hash values to
the net core.  Our hardware can pass a 32-bit hash value along with each
RX frame; I think this is a Windows requirement.  I would guess that we
would want to record the hash values for specific flows (assuming, of
course, that they are stable) as a basis for rebalancing them.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
