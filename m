From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: LRO restructuring?
Date: Wed, 18 Feb 2009 19:42:43 +0000
Message-ID: <1234986163.3183.14.camel@achroite>
References: <20080811.175434.215224347.davem@davemloft.net>
	 <20080812010004.GD18547@gondor.apana.org.au> <48A0E7A3.6030200@hp.com>
	 <20080811.183913.09225669.davem@davemloft.net>
	 <20080812015321.GA19011@gondor.apana.org.au>
	 <loom.20090218T192451-89@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Huang <jamesclhuang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:36717 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751379AbZBRTmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 14:42:46 -0500
In-Reply-To: <loom.20090218T192451-89@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-02-18 at 19:25 +0000, James Huang wrote:
> Hi Herbert,
> 
>     Any idea when this LRO restructuring work will be done? 
> Making LRO available even when ip forwarding is enabled will significantly 
> improve performace of network appliances in the data path.  

Herbert has added "GRO" rather than immediately replacing the inet_lro
code.  An early version of this is in 2.6.29 and there is more in
net-next-2.6 destined for 2.6.30.

> I have some questions on this: 
[...]
> (3) I think bridged packets should not be LROed. Whether a packet is bridged 
> or not can be based on the L2 MAC destination address.  Is this how it is done?

GRO preserves enough information to reconstruct the original frames on
output, so there is no specific check for bridging.  Presumably it would
be cheaper not to do use GRO if the frames are not going to hit the
TCP/IP stack though.

> (4) Does LRO work only for IPv4?  Any plan to extend it to support IPv6?

IPv6 is covered.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

