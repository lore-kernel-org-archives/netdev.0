From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [PATCH net-next 2/2] arp: flush arp cache on IFF_NOARP change
Date: Thu, 23 May 2013 15:01:02 +0300
Message-ID: <20130523150102.43010d84@vostro>
References: <1369303109-12003-1-git-send-email-timo.teras@iki.fi>
	<1369303109-12003-2-git-send-email-timo.teras@iki.fi>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7249@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "David Laight" <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:48081 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758514Ab3EWL70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 07:59:26 -0400
Received: by mail-ea0-f176.google.com with SMTP id k11so1803545eaj.21
        for <netdev@vger.kernel.org>; Thu, 23 May 2013 04:59:25 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7249@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 May 2013 11:23:28 +0100
"David Laight" <David.Laight@ACULAB.COM> wrote:

> > IFF_NOARP affects what kind of neighbor entries are created
> > (nud NOARP or nud INCOMPLETE). If the flag changes, flush the arp
> > cache to refresh all entries.
> 
> Might someone want to use this to stop further arp table
> entries being created?
> In which case you don't want anything flushed.

I don't think that would make any sense. The entries we have would
expire soon, and the other hosts would not be able to get arp replies
for our host.

Normally this flag is not changed. My use case is with ip gre tunnels,
and starting opennhrp daemon. Opennhrp enables address resolution via
netlink for gre tunnels - it turns off NOARP flag and configures real
ARP off and enables netlink ARPD requests. If before startup there was
traffic to gre tunnel, there will be stale NOARP entries preventing
traffic after daemon is started.

- Timo
