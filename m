From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/12] smc911x: Fix SMC_WRITE_EEPROM_CMD macro
Date: Wed, 13 Sep 2006 21:01:43 +0200
Message-ID: <20060913190143.GA25007@electric-eye.fr.zoreil.com>
References: <200609132053.57258.bora.sahin@ttnet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:18316 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751118AbWIMTFJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 15:05:09 -0400
To: bora.sahin@ttnet.net.tr
Content-Disposition: inline
In-Reply-To: <200609132053.57258.bora.sahin@ttnet.net.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bora.sahin@ttnet.net.tr <bora.sahin@ttnet.net.tr> :
[...]
>  #define SMC_WRITE_EEPROM_CMD(cmd, addr)					\
>  	do {								\
> -		while (SMC_GET_E2P_CMD() & MAC_CSR_CMD_CSR_BUSY_);	\
> -		SMC_SET_MAC_CMD(MAC_CSR_CMD_R_NOT_W_ | a );		\
> -		while (SMC_GET_MAC_CMD() & MAC_CSR_CMD_CSR_BUSY_);	\
> +		while (SMC_GET_E2P_CMD() & E2P_CMD_EPC_BUSY_)		\
> +			cpu_relax();					\
> +		SMC_SET_E2P_DATA((v) & 0xFF);				\
> +		SMC_SET_E2P_CMD(E2P_CMD_EPC_BUSY_ | 			\
> +				(cmd) << 28 | ((addr) & 0xFF));		\
> +		while (SMC_GET_E2P_CMD() & E2P_CMD_EPC_BUSY_)		\
> +			cpu_relax();					\
>  	} while (0)

Macro abuse. It should be a function.

-- 
Ueimor
