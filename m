From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] tcp: accommodate sequence number to a peer's
 shrunk receive window caused by precision loss in window scaling
Date: Fri, 17 Feb 2017 11:08:58 -0500 (EST)
Message-ID: <20170217.110858.1023681409351044871.davem@davemloft.net>
References: <41B57547-A148-49D5-8F03-18F976263CED@netapp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net
To: Cheng.Cui@netapp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44658 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934088AbdBQQJB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 11:09:01 -0500
In-Reply-To: <41B57547-A148-49D5-8F03-18F976263CED@netapp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Cui, Cheng" <Cheng.Cui@netapp.com>
Date: Tue, 14 Feb 2017 23:14:59 +0000

> This updates tcp_acceptable_seq(), one of the oldest functions since 2.4.0, by
> preventing sending out a left-shifted sequence number from a Linux sender in
> response to a peer's shrunk receive-window caused by losing least significant
> bits in window-scaling.
> 
> RFC7323 page 10 (Chapter 2.4. Addressing Window Retraction) specifies sender
> side responsibility to handle the sequence number out of window:
>> On the sender side:
>> 
>>    3)  The initial transmission MUST be within the window announced by
>>        the most recent <ACK>.
> 
> Some related discussion can be found at the IETF [tcpm] mailing list:
> https://mailarchive.ietf.org/arch/msg/tcpm/pPO7cYxtky27Qto9b30eaHB_RQI
> 
> The issue has been reproduced and the patch has been verified by scp a 20GB file
> from a Linux box using kernel version 4.4.48 to a FreeBSD 11.0 box.
> 
> [ I mainly want feedback to see if everyone is OK with the approach. ]
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Cheng Cui <Cheng.Cui@netapp.com>

Patch looks fine to me, but too much parenthesis in the initial conditional and
it's easier to see to high level structure if you format the check like this;

	if (!before(tcp_wnd_end(tp), tp->snd_nxt) ||
	    (tp->rx_opt.wscale_ok &&
	     ((tp->snd_nxt - tcp_wnd_end(tp)) < (1 << tp->rx_opt.rcv_wscale))))

THanks.
