From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: ATM bug found
Date: Sun, 1 Oct 2006 07:58:29 -0700
Message-ID: <20061001145829.GA83074@gaz.sfgoth.com>
References: <451FC182.6000502@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas@cmf.nrl.navy.mil, Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gaz.sfgoth.com ([69.36.241.230]:64243 "EHLO gaz.sfgoth.com")
	by vger.kernel.org with ESMTP id S1750719AbWJAOqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2006 10:46:31 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <451FC182.6000502@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(trimmed cc:'s since, IMO, isn't really all that general interest)

Jeff Garzik wrote:
> drivers/atm/zatm.c: In function ?zatm_open?:
> drivers/atm/zatm.c:919: warning: ?pcr? may be used uninitialized in this 
> function

Yeah, looks like a bug.  Not very high-impact because:
  1. it only results in garbled data in vcc->qos.txtp which doesn't
     really mean much for UBR vcc's anyway
  2. zatm is a more-obscure-than-obscure piece of hardware.  I'm sure
     3c501.c has more users these days :-)

The fix is for alloc_shaper() should really do "*pcr = ATM_MAX_PCR" in
the "if (ubr)" stanza.  Chas, want to submit that in the next batch
of patches?

-Mitch
