From: Paul Mackerras <paulus@samba.org>
Subject: Re: [Bugme-new] [Bug 6530] New: MAINLINE
Date: Thu, 11 May 2006 14:01:54 +1000
Message-ID: <17506.46898.503580.4994@cargo.ozlabs.ibm.com>
References: <200605100920.k4A9KC91018259@fire-2.osdl.org>
	<20060510023357.0d1260ee.akpm@osdl.org>
	<17505.49174.848331.686297@cargo.ozlabs.ibm.com>
	<20060510202943.35f548db.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:12722 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S965129AbWEKECG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 May 2006 00:02:06 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060510202943.35f548db.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton writes:

> xeb has said:
> 
> in this construction:
> 
>           if ((test_bit(XMIT_WAKEUP, &ap->xmit_flags) ||
>              test_bit(XMIT_FULL, &ap->xmit_flags)) && ppp_async_push(ap))
>                   ppp_output_wakeup(&ap->chan);
> 
> if ppp_async_push() doesn't send any data i.e.  XMIT_FULL is set then all
> (transfer) hangs up while somebody push again, for instance lcp-echo.  

If XMIT_FULL and ppp_async_push doesn't send any data, that means the
serial driver's output buffer was full.  If that's the case, *and* we
don't see a call to ppp_output_wakeup, then the finger points squarely
at the serial driver as the source of the bug.

Paul.
