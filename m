From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Subject: RE: [PATCH] net: stmmac: synchronize stmmac_open and
 stmmac_dvr_probe
Date: Tue, 27 Dec 2016 05:26:43 +0000
Message-ID: <F54AEECA5E2B9541821D670476DAE19C5A91691E@PGSMSX102.gar.corp.intel.com>
References: <1482839100-20612-1-git-send-email-hock.leong.kweh@intel.com>
 <20161226.235436.131087168899382517.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Joao.Pinto@synopsys.com" <Joao.Pinto@synopsys.com>,
        "peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
        "seraphin.bonnaffe@st.com" <seraphin.bonnaffe@st.com>,
        "alexandre.torgue@gmail.com" <alexandre.torgue@gmail.com>,
        "manabian@gmail.com" <manabian@gmail.com>,
        "niklas.cassel@axis.com" <niklas.cassel@axis.com>,
        "johan@kernel.org" <johan@kernel.org>,
        "pavel@ucw.cz" <pavel@ucw.cz>,
        "Ong, Boon Leong" <boon.leong.ong@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Voon, Weifeng" <weifeng.voon@intel.com>,
        "lars.persson@axis.com" <lars.persson@axis.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:11707 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750807AbcL0F0s (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Dec 2016 00:26:48 -0500
In-Reply-To: <20161226.235436.131087168899382517.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, December 27, 2016 12:55 PM
> To: Kweh, Hock Leong <hock.leong.kweh@intel.com>
> Cc: Joao.Pinto@synopsys.com; peppe.cavallaro@st.com;
> seraphin.bonnaffe@st.com; alexandre.torgue@gmail.com;
> manabian@gmail.com; niklas.cassel@axis.com; johan@kernel.org;
> pavel@ucw.cz; Ong, Boon Leong <boon.leong.ong@intel.com>;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Voon, Weifeng
> <weifeng.voon@intel.com>; lars.persson@axis.com
> Subject: Re: [PATCH] net: stmmac: synchronize stmmac_open and
> stmmac_dvr_probe
> 
> From: "Kweh, Hock Leong"	<hock.leong.kweh@intel.com>
> Date: Tue, 27 Dec 2016 19:44:59 +0800
> 
> > From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
> >
> > If kernel module stmmac driver being loaded after OS booted, there is a
> > race condition between stmmac_open() and stmmac_mdio_register(), which is
> > invoked inside stmmac_dvr_probe(), and the error is showed in dmesg log as
> > PHY not found and stmmac_open() failed:
>  ...
> > The resolution used wait_for_completion_interruptible() to synchronize
> > stmmac_open() and stmmac_dvr_probe() to prevent the race condition
> > happening.
> >
> > Signed-off-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>
> 
> The proper thing to do is to make sure register_netdevice() is not
> invoked until it is %100 safe to call stmmac_open().

Noted & thanks. Will look into it.

Regards,
Wilson
