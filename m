From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Check skb->rxhash in gro_receive
Date: Tue, 14 Jan 2014 18:27:07 -0800
Message-ID: <1389752827.31367.314.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
	 <1389332287.31367.88.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx_c=we-13b0Vyrim0=kArhx0OYY1P99HwUeuR2w87hRFw@mail.gmail.com>
	 <20140113.115913.1269834557058575064.davem@davemloft.net>
	 <1389644256.31367.223.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1389646213.2025.159.camel@bwh-desktop.uk.level5networks.com>
	 <1389649061.31367.236.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1389749477.3720.173.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f43.google.com ([209.85.213.43]:53496 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174AbaAOC1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 21:27:09 -0500
Received: by mail-yh0-f43.google.com with SMTP id a41so369980yho.2
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 18:27:09 -0800 (PST)
In-Reply-To: <1389749477.3720.173.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-15 at 01:31 +0000, Ben Hutchings wrote:

> When I investigated the scope of this for Debian, I tried sending a
> 'packet of death' to a VM and actually triggered the lockup in the TX
> path of the *host*, running Debian unstable with Linux 3.11.  I didn't
> track down exactly why that was but I think that libvirt's default
> networking configuration includes multiqueue devices that use flow
> dissector.

OK, I take that majority of debian hosts are running some VM then,
nice to know, time to update my hosts and usages I guess.

Anyway, current flow dissector needs care if we really use it in
unprotected areas.

Hostile packets can force flow dissection of MTU bytes,
bringing host to abysmal performance.

Once we fix all the issues, we'll see how expensive it is and
if it really can help.

Last year, my experiments were exactly using it in GRO, to
have a hash table instead of a single gro_list, unfortunately
this added a latency regression that I found not acceptable at that
time.

With TSO auto sizing, I might need to revisit the idea anyway...
