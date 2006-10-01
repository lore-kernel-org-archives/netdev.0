From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: ATM firestream bug
Date: Sun, 1 Oct 2006 08:10:41 -0700
Message-ID: <20061001151041.GC83074@gaz.sfgoth.com>
References: <451FD494.1090804@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gaz.sfgoth.com ([69.36.241.230]:42484 "EHLO gaz.sfgoth.com")
	by vger.kernel.org with ESMTP id S1750710AbWJAO6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2006 10:58:23 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <451FD494.1090804@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> 1) not safe on 64-bit

Almost certainly correct.  Probably never will be -- IIRC this SAR was
mainly used in embedded apps.  I don't know if any commercially-available
PCI cards were ever made with it.  I could be wrong though, it's been awhile
since I was up on the ATM industry.

> 2) variable 'tmc0' is indeed potentially used uninit'd, in particular if 
> make_rate() returns an error (use occurs before error check).

Exact same error as the one you spotted in ambassador.c -- make_rate()'s
error is not checked at all.  It should be.

-Mitch
