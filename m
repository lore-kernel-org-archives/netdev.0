From: bora.sahin@ttnet.net.tr
Subject: Re: [PATCH 2/12] smc911x: Fix SMC_WRITE_EEPROM_CMD macro
Date: Thu, 14 Sep 2006 11:46:13 +0300
Message-ID: <200609141146.14129.bora.sahin@ttnet.net.tr>
References: <200609132053.57258.bora.sahin@ttnet.net.tr> <20060913190143.GA25007@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="Iso-8859-9"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeus1.kernel.org ([204.152.191.4]:25728 "EHLO zeus1.kernel.org")
	by vger.kernel.org with ESMTP id S1751460AbWINImb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 04:42:31 -0400
Received: from fep04.ttnet.net.tr (mail.ttnet.net.tr [212.175.13.129])
	by zeus1.kernel.org (8.13.7/8.13.1) with ESMTP id k8E8g9kX007054
	for <netdev@vger.kernel.org>; Thu, 14 Sep 2006 08:42:29 GMT
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060913190143.GA25007@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

Thanks for your comments.

On Wednesday 13 September 2006 22:01, Francois Romieu wrote:
> bora.sahin@ttnet.net.tr <bora.sahin@ttnet.net.tr> :
> [...]
> >  #define SMC_WRITE_EEPROM_CMD(cmd, addr)					\
> >  	do {								\
> > -		while (SMC_GET_E2P_CMD() & MAC_CSR_CMD_CSR_BUSY_);	\
> > -		SMC_SET_MAC_CMD(MAC_CSR_CMD_R_NOT_W_ | a );		\
> > -		while (SMC_GET_MAC_CMD() & MAC_CSR_CMD_CSR_BUSY_);	\
> > +		while (SMC_GET_E2P_CMD() & E2P_CMD_EPC_BUSY_)		\
> > +			cpu_relax();					\
> > +		SMC_SET_E2P_DATA((v) & 0xFF);				\
> > +		SMC_SET_E2P_CMD(E2P_CMD_EPC_BUSY_ | 			\
> > +				(cmd) << 28 | ((addr) & 0xFF));		\
> > +		while (SMC_GET_E2P_CMD() & E2P_CMD_EPC_BUSY_)		\
> > +			cpu_relax();					\
> >  	} while (0)
> 
> Macro abuse. It should be a function.
 
Yes but I got smc911x.h and smc91x.h as a basis. In the smc911x.c there are macros
which is longer than it, e.g. SMC_GET_MII. In the same way, smc91x.h contains even
more longer like SMC_PUSH_DATA. But, of course, it doesnt mean they are correct.
It's two different things. Just want to explain it.

Do you think if I convert them(smc911x.h) to static inline, would that be correct?

--
Bora SAHIN
