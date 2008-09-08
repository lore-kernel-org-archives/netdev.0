From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] SMSC LAN9500 USB2.0 10/100 ethernet adapter driver
Date: Mon, 8 Sep 2008 11:36:17 -0700
Message-ID: <200809081136.17766.david-b@pacbell.net>
References: <1220611890-6477-1-git-send-email-steve.glendinning@smsc.com> <20080906150932.630C.40F06B3A@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>,
	Catalin Marinas <catalin.marinas@arm.com>
To: Masakazu Mokuno <mokuno@sm.sony.co.jp>,
	Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp121.sbc.mail.sp1.yahoo.com ([69.147.64.94]:37409 "HELO
	smtp121.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751713AbYIHSgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 14:36:20 -0400
In-Reply-To: <20080906150932.630C.40F06B3A@sm.sony.co.jp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 08 September 2008, Masakazu Mokuno wrote:
> > +=A0=A0=A0=A0=A0/* 40ms total */
> As smsc95xx_read_reg() uses the synchronous urb call and AFAIR ehci
> would defer the interrupts until 8 micro-frames by default, so I gues=
s this
> loop would take more than 40ms?

Don't assume this always works with EHCI ... there are systems
that will use it with full speed host controllers.  And for that
matter, an increasing number of non-EHCI high speed hosts.

And on Linux, we override that slow default setting and tell
EHCI to interrupt us as soon as the transfer is done.  (There
are better interrupt mitigation schemes in place.  For example
the "usbnet" framework avoids IRQs after most packets and
the mass storage driver can read or write hundreds of KBytes
with a single IRQ.)

In general, calling udelay() in this level of USB driver should
be avoided in favor of msleep() or similar.  Spinning the CPU
will just waste power.


I suggest you cc linux-usb@vger to get more usb-aware review
of this code...=20

- Dave
