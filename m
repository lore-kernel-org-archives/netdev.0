From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Subject: RE: [PATCH v2] net: stmmac: bug fix to synchronize stmmac_open and
 stmmac_dvr_probe
Date: Wed, 28 Dec 2016 05:49:18 +0000
Message-ID: <F54AEECA5E2B9541821D670476DAE19C5A916CA0@PGSMSX102.gar.corp.intel.com>
References: <1482849756-21817-1-git-send-email-hock.leong.kweh@intel.com>
 <20161227.113405.362102687632949941.davem@davemloft.net>
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
        "Voon, Weifeng" <weifeng.voon@intel.com>,
        "lars.persson@axis.com" <lars.persson@axis.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161227.113405.362102687632949941.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, December 28, 2016 12:34 AM
> To: Kweh, Hock Leong <hock.leong.kweh@intel.com>
> Cc: Joao.Pinto@synopsys.com; peppe.cavallaro@st.com;
> seraphin.bonnaffe@st.com; f.fainelli@gmail.com;
> alexandre.torgue@gmail.com; manabian@gmail.com; niklas.cassel@axis.com;
> johan@kernel.org; pavel@ucw.cz; Ong, Boon Leong
> <boon.leong.ong@intel.com>; Voon, Weifeng <weifeng.voon@intel.com>;
> lars.persson@axis.com; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH v2] net: stmmac: bug fix to synchronize stmmac_open and
> stmmac_dvr_probe
> 
> From: "Kweh, Hock Leong"	<hock.leong.kweh@intel.com>
> Date: Tue, 27 Dec 2016 22:42:36 +0800
> 
> > From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
> 
> You are not the author of this change, do not take credit for it.
> 
> You have copied Florian's patch character by character, therefore
> he is the author.
> 
> You also didn't CC: the netdev mailing list properly.

Hi David & Florian,

Just to clarify that I do not copy exactly from Florian.
I have changed it to have proper handling on mdio unregister
while netdev_register() failed as showed below:

	return 0;
 
-error_mdio_register:
-	unregister_netdev(ndev);
 error_netdev_register:
+	stmmac_mdio_unregister(ndev);
+error_mdio_register:
	netif_napi_del(&priv->napi);

Vs 

+
+       return ret;

 error_mdio_register:
-       unregister_netdev(ndev);
-error_netdev_register:
        netif_napi_del(&priv->napi);

Just to point it out here, so that Florian could aware if he/she submit
this fix to the mailing list.


Thanks & Regards,
Wilson  
