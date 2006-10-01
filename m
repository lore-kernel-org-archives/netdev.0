From: Jeff Garzik <jeff@garzik.org>
Subject: ATM bug found
Date: Sun, 01 Oct 2006 09:24:18 -0400
Message-ID: <451FC182.6000502@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:3722 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932146AbWJANYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2006 09:24:22 -0400
To: chas@cmf.nrl.navy.mil, Netdev List <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unlike 98% of the warnings of this type, this gcc warning does indeed=20
seem to indicate a bug:

drivers/atm/zatm.c: In function =91zatm_open=92:
drivers/atm/zatm.c:919: warning: =91pcr=92 may be used uninitialized in=
 this=20
function

If alloc_shaper() argument 'unlimited' is true, then pcr is never=20
assigned a value.  However, the caller of alloc_shaper() always tests=20
the pcr value, regardless of whether or not 'unlimited' is true.

	Jeff


