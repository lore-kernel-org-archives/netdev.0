From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [Security, resend] Instant crash with rtl8169 and large packets
Date: Mon, 08 Jun 2009 23:28:54 +0400
Message-ID: <4A2D6676.1030607@msgid.tls.msk.ru>
References: <4A2D1147.8020101@msgid.tls.msk.ru> <4A2D1FE4.5030100@gmail.com> <4A2D25F6.9080300@msgid.tls.msk.ru> <4A2D2906.6090002@gmail.com> <4A2D301D.9040301@msgid.tls.msk.ru> <4A2D3568.6010901@gmail.com> <4A2D3BC6.3040904@msgid.tls.msk.ru> <4A2D4AA7.6020204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([81.13.33.159]:55924 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755351AbZFHT2z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2009 15:28:55 -0400
In-Reply-To: <4A2D4AA7.6020204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> OK I suspect driver is buggy since 2.6.10 days :)

I browsed the git history for a while but don't see since
when it might be broken.  But again, I don't know the code
nor the hardware.

> Could you try this patch ?

That makes quite some sense, except of two comments - pure
speculation/guesses really, since I don't know the hw.

The patch does not re-program the card when we change MTU
(where we merely set internal rx_buf_sz, but don't tell the
card about this).  Maybe we should call this method in
rtl8169_set_rxbufsize() too?

I don't know almost anything about things like vlans for
example, but guess they use some additional headers.  Does
those need some space too?  Maybe its better to allocate
"a bit" more room in skb for that stuff?

Recompiling the driver now...

/mjt
