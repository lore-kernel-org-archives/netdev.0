From: Radha Mohan <radhamohan_ch@yahoo.com>
Subject: Re: behavior of TSO in kernel
Date: Mon, 29 Jun 2009 12:14:55 +0530 (IST)
Message-ID: <974032.57711.qm@web94813.mail.in2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from n3-vm0.bullet.mail.in.yahoo.com ([202.86.5.188]:43901 "HELO
	n3-vm0.bullet.mail.in.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751445AbZF2Goz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 02:44:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David,

I think we do not need to do this when TSO is enabled.

At line 1562 in tcp_output.c (in tcp_write_xmit() function)

    if (tso_segs > 1 && !tcp_urg_mode(tp))
           limit = tcp_mss_split_point(sk, skb, mss_now,
                                            cwnd_quota);
    if (skb->len > limit &&
                    unlikely(tso_fragment(sk, skb, limit, mss_now)))

Since the hardware can split and send the packet, there is 
no need for this in software.

Am I missing something here?

-- Mohan



----- Original Message ----
From: Radha Mohan <radhamohan_ch@yahoo.com>
To: netdev@vger.kernel.org
Cc: David Miller <davem@davemloft.net>
Sent: Saturday, 6 June, 2009 7:41:21 PM
Subject: Re: behavior of TSO in kernel


>The TSO engine of the networking has been rewritten at least
>3 times since 2.6.15
Thank you for the info.
Actually we are working on an SoC and we just started moving from kernel 2.6.15, so can you tell me from which kernel version the latest TSO engine is being used. That'll make our life easier and avoid moving kernels frequently. Currently we are thinking of moving to 2.6.24. Will that do??


      ICC World Twenty20 England &#39;09 exclusively on YAHOO! CRICKET http://cricket.yahoo.com

