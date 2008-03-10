From: Paul Gortmaker <p_gortmaker@yahoo.com>
Subject: Re: drivers/net/tokenring/smctr.c: logical-bitwise or confusion?
Date: Sun, 9 Mar 2008 20:09:39 -0400 (EDT)
Message-ID: <993737.45508.qm@web65610.mail.ac4.yahoo.com>
References: <47D45A0F.1060102@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Roel Kluin <12o3l@tiscali.nl>, jschlst@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web65610.mail.ac4.yahoo.com ([76.13.9.78]:28521 "HELO
	web65610.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753662AbYCJAQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2008 20:16:23 -0400
In-Reply-To: <47D45A0F.1060102@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--- Roel Kluin <12o3l@tiscali.nl> wrote:

> drivers/net/tokenring/smctr.c:3416
> 
> tsv->svv[0] = ((tx_fstatus & 0x0100 >> 6) || IBM_PASS_SOURCE_ADDR);
> 
> shouldn't this be a bit-wise or?
> from drivers/net/tokenring/smctr.h:50:
> 
> #define      IBM_PASS_SOURCE_ADDR    0x01

Probably a safe bet that is what they meant to have. Since
as it stands, gcc will (correctly) optimize that into:

tsv->svv[0]= 1;

which probably isn't particularly useful.

Paul.
 



      Connect with friends from any web browser - no download required. Try the new Yahoo! Canada Messenger for the Web BETA at http://ca.messenger.yahoo.com/webmessengerpromo.php
