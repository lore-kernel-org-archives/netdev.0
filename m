From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] pkt_sched: fq: avoid artificial bursts for
 clocked flows
Date: Tue, 03 Feb 2015 14:05:15 -0800
Message-ID: <1423001115.907.42.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1422903556-30393-1-git-send-email-kennetkl@ifi.uio.no>
	 <1422905092.21689.122.camel@edumazet-glaptop2.roam.corp.google.com>
	 <F3E6220B-F2F4-4985-AECE-9EB9AA7D1C20@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:50993 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752465AbbBCWFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 17:05:19 -0500
Received: by mail-ig0-f175.google.com with SMTP id hn18so30304493igb.2
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 14:05:19 -0800 (PST)
In-Reply-To: <F3E6220B-F2F4-4985-AECE-9EB9AA7D1C20@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-02-03 at 19:51 +0000, Kenneth Klette Jonassen wrote:

> > 
> > ACK packets are not paced, ever.
> > 
> > This patch also allows skb->ooo_okay being set even if the DATA packet
> > immediately follows a train of ACK packets (as in typical RPC patterns)
> > 
> Could you please expand on this?
> 

If you followed netdev recently, you might have noticed I am currently
upstreaming patches that we tested more than 6 months at Google.

I am doing this in a non bursty way to ease David Miller work ;)

A hint is given in commit b2532eb9abd88384a
("tcp: fix ooo_okay setting vs Small Queues")

  * TODO: Ideally, in-flight pure ACK packets should not matter here.
  * One way to get this would be to set skb->truesize = 2 on them.

Thanks
