From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Modifying the exponential backoff on new connection SYN packets
Date: Tue, 09 Apr 2013 06:48:03 -0700
Message-ID: <1365515283.3887.124.camel@edumazet-glaptop>
References: <5163DA09.5070202@wildgooses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: Ed W <lists@wildgooses.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f44.google.com ([209.85.210.44]:37522 "EHLO
	mail-da0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761860Ab3DINsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 09:48:06 -0400
Received: by mail-da0-f44.google.com with SMTP id z20so3064247dae.31
        for <netdev@vger.kernel.org>; Tue, 09 Apr 2013 06:48:05 -0700 (PDT)
In-Reply-To: <5163DA09.5070202@wildgooses.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-09 at 10:06 +0100, Ed W wrote:
> Hi, I have an unusual situation in that I would like to cap the 
> retransmit frequency on the initial SYN packets at some fairly short 
> time interval, eg a max of 2-4 seconds, rather than the usual 
> exponentially increasing interval.  I could use some help figuring out 
> the exact point in the kernel to make such a change please?
> 
> The situation is that I am building a firewall which will be used with 
> expensive satellite links (think $10-100/MB range). Some of the links 
> are dialup links which take 20-40 seconds to bring up, and then we have 
> PPP drop the link after 10 seconds of inactivity. However, with the 
> default exponential backoff on new connections we are generally 
> retransmitting with a 16sec or 32 sec interval by the time the dialup 
> link is connected, the timout for inactivity kicks in and drops the link 
> before the retransmit...
> 
> I believe the exponential backoff is intended to prevent amplification 
> attacks? In this particular case we are accounting for traffic per user 
> and the internet costs are extremely substantial, so I think it's not a 
> problem
> 
> Could someone please help figure out the appropriate place to tweak the 
> exponential backoff? Note this is not retransmit of in flight data, just 
> the backoff for the initial syn (which doesn't seem to be configurable 
> in user space?)
> 
> Note, we have an application proxy here, but I can't see a sensible way 
> to fake it in user space without a lot of extra coding - any suggestions?

You'll have to change inet_csk_reqsk_queue_prune() in
net/ipv4/inet_connection_sock.c

timeo = min(timeout << req->num_timeout, max_rto);
req->expires = now + timeo; 

Good luck !
