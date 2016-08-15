From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH v2 1/4] net: ethernet: ti: davinci_cpdma: split descs num
 between all channels
Date: Mon, 15 Aug 2016 16:05:53 +0000
Message-ID: <SN2PR11MB009489AF2C64CD34DE5473A597120@SN2PR11MB0094.namprd11.prod.outlook.com>
References: <1471274181-780-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1471274181-780-2-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"nsekhar@ti.com" <nsekhar@ti.com>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"mugunthanvnm@ti.com" <mugunthanvnm@ti.com>,
	"grygorii.strashko@ti.com" <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0123.outbound.protection.outlook.com ([104.47.37.123]:5984
	"EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752821AbcHOQF5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Aug 2016 12:05:57 -0400
In-Reply-To: <1471274181-780-2-git-send-email-ivan.khoronzhuk@linaro.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Currently the tx channels share same pool of descriptors. Thus one channel can
> block another if pool is emptied by one. But, the shaper should decide which
> channel is allowed to send packets. To avoid such impact of one channel on
> another, let every channel to have its own peace of pool.
Piece.
 
> +/**
> + * cpdma_chan_split_pool - Splits ctrl pool between all channels.
> + * Has to be called under ctlr lock
> + *
> + */
No need for the extra empty comment line.

> +	/* calculate average size of pool slice */
> +	ch_desc_num = pool->num_desc / ctlr->chan_num;
> +
> +	/* split ctlr pool */
> +	for (i = 0; i < ARRAY_SIZE(ctlr->channels); i++) {
> +		chan = ctlr->channels[i];
> +		if (chan)
> +			chan->desc_num = ch_desc_num;
Is this 'if' needed? If there's some route where the channel can be NULL,
You're splitting the value incorrectly.
