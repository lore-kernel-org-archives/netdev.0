From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: [PATCH] s2io: netpoll support
Date: Tue, 13 Jun 2006 16:33:10 -0700
Message-ID: <005401c68f41$bc4bfaa0$3e10100a@pc.s2io.com>
References: <448849F6.8050002@hp.com>
Reply-To: <ravinandan.arakali@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <jgarzik@pobox.com>,
	"Ananda. Raju \(E-mail\)" <ananda.raju@neterion.com>,
	"Leonid. Grossman \(E-mail\)" <leonid.grossman@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:47779 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S964801AbWFMXdB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 19:33:01 -0400
To: "'Brian Haley'" <brian.haley@hp.com>, <netdev@vger.kernel.org>
In-Reply-To: <448849F6.8050002@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't think we should disable and enable all interrupts in the
poll_controller entry point. With the current patch, at the end of
the routine _all_ interrupts get enabled which is not desirable.
Maybe you should just do disable_irq() at start of function and
enable_irq() before exiting, the way some of the other drivers do.

Ravi

-----Original Message-----
From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org]On Behalf Of Brian Haley
Sent: Thursday, June 08, 2006 9:02 AM
To: netdev@vger.kernel.org
Cc: jgarzik@pobox.com
Subject: [PATCH] s2io: netpoll support


This adds netpoll support for things like netconsole/kgdboe to the s2io
10GbE driver.

This duplicates some code from s2io_poll() as I wanted to be
least-invasive, someone from Neterion might have other thoughts?

Signed-off-by: Brian Haley <brian.haley@hp.com>

