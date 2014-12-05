From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH][net-next] net: avoid to call skb_queue_len again
Date: Fri, 05 Dec 2014 06:31:10 -0800
Message-ID: <1417789870.15618.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417772948-17909-1-git-send-email-roy.qing.li@gmail.com>
	 <5481BBF2.40806@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:51612 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965AbaLEObM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 09:31:12 -0500
Received: by mail-ig0-f176.google.com with SMTP id l13so913088iga.9
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 06:31:11 -0800 (PST)
In-Reply-To: <5481BBF2.40806@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-12-05 at 17:06 +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 12/5/2014 12:49 PM, roy.qing.li@gmail.com wrote:
> 
> > From: Li RongQing <roy.qing.li@gmail.com>
> 
> > the queue length of sd->input_pkt_queue has been putted into qlen,
> 
>     s/putted/put/, it's irregular verb.
> 
> > and impossible to change, since hold the lock
> 
>     I can't parse that. Who holds the lock?

This thread/cpu holds the lock to manipulate input_pkt_queue.

Otherwise, the following would break horribly....

__skb_queue_tail(&sd->input_pkt_queue, skb);
