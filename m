From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: No pmtu probing on retransmits?
Date: Sun, 3 Feb 2008 09:04:02 -0500
Message-ID: <1e41a3230802030604s247029a7yc0ffaa59622fb866@mail.gmail.com>
References: <20080203123719.GA3323@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:15696 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753895AbYBCOED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2008 09:04:03 -0500
Received: by wa-out-1112.google.com with SMTP id v27so2290415wah.23
        for <netdev@vger.kernel.org>; Sun, 03 Feb 2008 06:04:03 -0800 (PST)
In-Reply-To: <20080203123719.GA3323@basil.nowhere.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> Hallo,
>
> While looking for something else in tcp_output.c I noticed that
> MTU probing seems to be only done in tcp_write_xmit (when
> packets come directly from process context), but not via the timer
> driven timer retransmit path (tcp_retransmit_skb). Is that intentional?
> It looks quite weird. I would normally assume PMTU blackholes get usually
> detected on retransmit timeouts. Or do I miss something?

MTU probing occurs only when everything is going fine.  We are probing
a larger size than currently in use.  In the case of a timeout, we
want to retransmit with the safe smaller size.


> You seem to have assumed interrupt context at least
> because tcp_mtu_probe() uses GFP_ATOMIC which is only needed for
> interrupts. Currently it is only called in process context I think.

I'm pretty sure it'll get called on ACK processing in softirq, f.e.:
tcp_mtu_probe()
tcp_write_xmit()
__tcp_push_pending_frames()
tcp_data_snd_check()
tcp_rcv_established()

Am I missing something?

  -John
