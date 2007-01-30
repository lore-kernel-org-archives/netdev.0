From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: spidernet: add improved phy support in sungem_phy.c
Date: Tue, 30 Jan 2007 16:30:50 -0600
Message-ID: <20070130223050.GE5616@austin.ibm.com>
References: <200701261407.48237.jens@de.ibm.com> <1169842847.24996.106.camel@localhost.localdomain> <200701262331.58491.jens@de.ibm.com> <20070126233809.GA16660@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Osterkamp <jens@de.ibm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org, jgarzik@pobox.com,
	James K Lewis <jim@jklewis.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:33015 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751841AbXA3Way (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jan 2007 17:30:54 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l0UMUquc023204
	for <netdev@vger.kernel.org>; Tue, 30 Jan 2007 17:30:52 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0UMUqxW258118
	for <netdev@vger.kernel.org>; Tue, 30 Jan 2007 17:30:52 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0UMUp1b004524
	for <netdev@vger.kernel.org>; Tue, 30 Jan 2007 17:30:52 -0500
Content-Disposition: inline
In-Reply-To: <20070126233809.GA16660@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 27, 2007 at 12:38:09AM +0100, Francois Romieu wrote:
> Jens Osterkamp <jens@de.ibm.com> :
> > 
> Index: linux-2.6.20-rc5/drivers/net/sungem_phy.c
> ===================================================================
> --- linux-2.6.20-rc5.orig/drivers/net/sungem_phy.c
> +++ linux-2.6.20-rc5/drivers/net/sungem_phy.c
> @@ -311,6 +311,107 @@ static int bcm5411_init(struct mii_phy* 
> [...]
> +	if ( (phy_reg & 0x0020) >> 5 ) {

Shifting to the right by 5 bits has no effect on the result
of this conditional. Either the bit is set, or its not.
There is no need to shift.

> +	if ( (phy_reg & 0x0020) >> 7 ) {

The result here will always be zero, since the bit,
if set, will be shifted off the end. Bits on the lef
are padded with zero.  Ergo, this is a bug.

--linas
