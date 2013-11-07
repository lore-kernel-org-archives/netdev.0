From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Using HTB over MultiQ
Date: Thu, 07 Nov 2013 06:29:46 -0800
Message-ID: <1383834586.9412.65.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAEzD07+Haf-Kg52H7GsxC5XiQn2KXozHbxgL4Lvn0grhFXVFmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Anton 'EvilMan' Danilov <littlesmilingcloud@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:35225 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083Ab3KGO3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 09:29:48 -0500
Received: by mail-pd0-f180.google.com with SMTP id p10so670914pdj.11
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 06:29:48 -0800 (PST)
In-Reply-To: <CAEzD07+Haf-Kg52H7GsxC5XiQn2KXozHbxgL4Lvn0grhFXVFmA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-07 at 17:12 +0400, Anton 'EvilMan' Danilov wrote:

> But I see zero statistics on the leaf htb classes and nonzero
> statistics on the classifier filters:
> 
> ~$ tc -s -p filter list dev eth1
>  ...
>  filter parent 10: protocol ip pref 5 u32 fh 2:f2:800 order 2048 key
> ht 2 bkt f2 flowid 11:1736  (rule hit 306 success 306)
>    match IP src xx.xx.xx.xx/30 (success 306 )
>  ...

Filter matches and flowid 11:1736 chosen

But then, when the packet enters HTB, it enters HTB on one of the 8 HTB
trees, and only one of them contains 11:1736 and could queue the packet
into its local pfifo 50.

For 7 others HTB trees, flowid 11:1736 doesn't match any htb class, so
packet is queued into the default queue attached to the HTB tree.

> 
> ~$ tc -s -s -d c ls dev eth1 classid 11:1736
>  class htb 11:1736 parent 11:1 leaf 1736: prio 0 quantum 12800 rate
> 1024Kbit ceil 1024Kbit burst 1599b/1 mpu 0b overhead 0b cburst 1599b/1
> mpu 0b overhead 0b level 0
>   Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>   rate 0bit 0pps backlog 0b 0p requeues 0
>   lended: 0 borrowed: 0 giants: 0
>   tokens: 195312 ctokens: 195312
