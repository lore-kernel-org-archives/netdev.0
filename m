From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH] qed: Add and use specific logging functions to reduce
 object size
Date: Wed, 27 Jul 2016 07:24:17 +0000
Message-ID: <CO2PR11MB00889101E00EA4328672A374970F0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <a0e0111217e9df2ae8dfd681b2810230e00f634e.1469568146.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Dept-Eng Everest Linux L2 <Dept-EngEverestLinuxL2@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0139.outbound.protection.outlook.com ([104.47.32.139]:53601
	"EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751561AbcG0H6Q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 03:58:16 -0400
In-Reply-To: <a0e0111217e9df2ae8dfd681b2810230e00f634e.1469568146.git.joe@perches.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Current DP_<LEVEL> macros generate a lot of code.
> Using functions with vsprintf extension %pV helps reduce that size.
> 
>  drivers/net/ethernet/qlogic/qed/Makefile   |  2 +-
>  drivers/net/ethernet/qlogic/qed/qed_util.c | 82
> ++++++++++++++++++++++++++++++
>  include/linux/qed/qed_if.h                 | 60 +++++++++-------------
>  3 files changed, 106 insertions(+), 38 deletions(-)  create mode 100644
> drivers/net/ethernet/qlogic/qed/qed_util.c

This won't compile when CONFIG_QED*=m, as qede can't link to
the new qed_{err, verbose, info, notice} functions.
That was the original reason for putting the macros in the interface
header.

Other alternatives:
- We can EXPORT_SYMBOL() the functions, although we've taken a
strain not adding such to the interface.
 - Code duplication between qed/qede [ugly].
 - Implementing this in qede via the interface functions with qed; 
But the notion of defining an interface between 2 modules passing
va_args seems [to me] like a bad one.

If you have cleaner solutions, I'd be happy to hear those.
