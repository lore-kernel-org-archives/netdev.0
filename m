From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [net-next:master 98/98] drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34:
 sparse: cast to restricted __be16
Date: Mon, 03 Dec 2012 14:21:14 -0500
Message-ID: <50BCFBAA.5060001@myri.com>
References: <50b91efa.B0WbOtcWMs7eOSaC%fengguang.wu@intel.com> <50B92A6D.8000600@myri.com> <20121130220228.GA22050@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Christopher Li <sparse@chrisli.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f174.google.com ([209.85.213.174]:49289 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738Ab2LCTVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 14:21:18 -0500
Received: by mail-ye0-f174.google.com with SMTP id m6so459135yen.19
        for <netdev@vger.kernel.org>; Mon, 03 Dec 2012 11:21:17 -0800 (PST)
In-Reply-To: <20121130220228.GA22050@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think I have a handle on most of the pre-existing warnings.  The
device responds to BAR reads/writes with big endian data, while
I think everything expects little endian.  These will be easy
to fix. The warning I don't see a fix for is this:

drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1434:35: warning:
context imbalance in 'myri10ge_intr' - different lock contexts for basic
block

Which is apparently triggered by using __netif_tx_trylock().
Is there something I'm missing, or does sparse just not like
__netif_tx_trylock() because it divides spinlock acquisition and
release into 2 different functions?

Thanks,

Drew
