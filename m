From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH RFC] isdn/capi: fix up CAPI subsystem workaround locking a bit
Date: Sat, 3 Oct 2009 20:26:22 +0200
Message-ID: <200910032026.24451.mb@bu3sch.de>
References: <20091003120657.2228911186C@xenon.ts.pxnet.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: i4ldeveloper@listserv.isdn4linux.de,
	Carsten Paeth <calle@calle.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	Karsten Keil <keil@b1-systems.de>,
	Armin Schindler <armin@melware.de>,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756857AbZJCS1J@vger.kernel.org>
In-Reply-To: <20091003120657.2228911186C@xenon.ts.pxnet.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 03 October 2009 14:06:57 Tilman Schmidt wrote:
> Move calls to handle_minor_send() and handle_minor_recv() out of
> the sections locked by workaround_lock.
> - handle_minor_send() may call another CAPI function via the card
>   driver, deadlocking by trying to take workaround_lock again.
> - handle_minor_recv() calls the receive_buf method of the active
>   line discipline which may sleep.

I remember that handle_minor_send() and/or handle_minor_recv() showed up
in the crash backtraces. So if you move them out of the critical
section, you can as well remove the lock completely.

-- 
Greetings, Michael.
