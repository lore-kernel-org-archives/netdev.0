From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v3 1/1] net: fec: ptp: avoid register access when ipg
 clock is disabled
Date: Mon, 18 Aug 2014 21:42:10 +0200
Message-ID: <20140818194151.GA4048@netboy>
References: <1408081975-15087-1-git-send-email-b38611@freescale.com>
 <1408081975-15087-2-git-send-email-b38611@freescale.com>
 <20140815180854.GA6897@localhost.localdomain>
 <b50df5011728419887508cbf3af0a5a7@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:48039 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbaHRTmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2014 15:42:17 -0400
Received: by mail-qg0-f41.google.com with SMTP id z107so1580378qgd.28
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2014 12:42:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <b50df5011728419887508cbf3af0a5a7@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 18, 2014 at 06:07:00AM +0000, fugang.duan@freescale.com wrote:
> 1. Set the flag to false firstly.

Yes.

> 2. Don't need to add mutex to protect the flag.(My previous mail ask one mutex to protect the flag)

You *do* need a mutex to protect the state of the physical clock. One
process might turn it off while another process is still reading it.

>    Just pull the flag into the protected field by spin_lock_irqsave() like :
> fec_time_keep()

No, the spin only protects the register access.

Thanks,
Richard
