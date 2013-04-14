From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 3/9] qlcnic: Add identifying string for 83xx
 adapter
Date: Sun, 14 Apr 2013 12:55:24 +0200
Message-ID: <20130414105524.GB30385@electric-eye.fr.zoreil.com>
References: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
 <1365874114-6759-4-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44070 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330Ab3DNKzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 06:55:31 -0400
Content-Disposition: inline
In-Reply-To: <1365874114-6759-4-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shahed Shaikh <shahed.shaikh@qlogic.com> :
[...]
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> index 0d00b2b..424a5e0 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> @@ -156,6 +156,37 @@ static const u32 qlcnic_reg_tbl[] = {
>  };
>  
>  static const struct qlcnic_board_info qlcnic_boards[] = {
> +	{0x1077, 0x8030, 0x1077, 0x24e,

You may consider adding a space after the curly brace at a later time.

> +	 "8300 Series Dual Port 10GbE Converged Network Adapter "
> +	 "(TCP/IP Networking)"},
> +	{0x1077, 0x8030, 0x1077, 0x243,

0x1077 is also known as PCI_VENDOR_ID_QLOGIC.

You should imho use a macro to factor out the vendor.

At your choice, you may:
1. try a second macro to paste "Converged Network Adapter (TCP/IP Networking)"
2. save some kernel memory through replacement of
   short_name[QLCNIC_MAX_BOARD_NAME_LEN] (short indeed :o) ) by a char **.

Nit: rework qlcnic_get_board_name to avoid its sprintf and 
     QLCNIC_MAX_BOARD_NAME_LEN sized string in qlcnic_probe.

-- 
Ueimor
