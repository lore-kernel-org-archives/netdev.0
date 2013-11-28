From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net] r8169: check ALDPS bit and disable it if enabled for the 8168g
Date: Thu, 28 Nov 2013 11:37:18 +0800
Message-ID: <103D217663F345E1877FB05AC93E3CFF@realtek.com.tw>
References: <1385538516-32104-1-git-send-email-dchang@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>,
	'Francois Romieu' <romieu@fr.zoreil.com>, <jlee@suse.com>,
	'nic_swsd' <nic_swsd@realtek.com>
To: 'David Chang' <dchang@suse.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:60860 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754257Ab3K1Dhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 22:37:35 -0500
In-Reply-To: <1385538516-32104-1-git-send-email-dchang@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 David Chang [mailto:dchang@suse.com] 
> Sent: Wednesday, November 27, 2013 3:49 PM
> To: netdev@vger.kernel.org
> Cc: David S. Miller; Francois Romieu; Hayeswang; jlee@suse.com
> Subject: [PATCH net] r8169: check ALDPS bit and disable it if 
> enabled for the 8168g
> 
[...]
> +	/* Check ALDPS bit, disable it if enabled */
> +	rtl_writephy(tp, 0x1f, 0x0a43);
> +	if (rtl_readphy(tp, 0x10) & 0x0004)
> +		rtl_w1w0_phy(tp, 0x10, 0x0000, 0x0004);
> +

You have to delay at least 10 ms after disable it.
This makes sure the hw completes the action.
 
Best Regards,
Hayes
