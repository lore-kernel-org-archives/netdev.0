From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] [1/1] Deprecate tcp_tw_{reuse,recycle}
Date: Thu, 31 Jan 2008 03:59:07 +0100
Message-ID: <200801310359.07362.ak@suse.de>
References: <20080130938.523292915@suse.de> <47A0CE75.5080200@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:51176 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763635AbYAaDAc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 22:00:32 -0500
In-Reply-To: <47A0CE75.5080200@candelatech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 30 January 2008 20:22, Ben Greear wrote:

> We use these features to enable creating very high numbers of short-lived
> TCP connections, primarily used as a test tool for other network
> devices.

Hopefully these other network devices don't do any NAT then
or don't otherwise violate the IP-matches-PAWS assumption.
Most likely they do actually, so enabling TW recycle
for testing is probably not even safe for you.

Modern systems have a lot of RAM so even without tw recycle
you should be able to get a very high number of connections.
An timewait socket is around 128 bytes on 64bit; this means
with a GB of memory you can already support > 8 Million TW sockets.
On 32bit it's even more.

The optimization was originally written at a time when 64MB systems
were common.

If you don't care about data integrity have you considered just 
using some custom UDP based protocol or run one of the user space
TCP stacks and disable all data integrity features? If you do care about
data integrity then you should probably disable tw recycle anyways.

The deprecation period will be some time (several months) so you'll have 
enough time to migrate to another method

> Perhaps just document the adverse affects and/or have it print out a
> warning on the console whenever the feature is enabled?

"This feature is insecure and does not work on the internet or with NAT" ? 

Somehow this just does not seem right to me. 

-Andi
