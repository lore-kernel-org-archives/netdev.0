From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH 1/1] driver/net: add missing rtnl lock/unlock for benet
Date: Tue, 15 Apr 2014 11:57:41 +0000
Message-ID: <069bdb52-6176-407a-b7fc-3f23a944a529@CMEXHTCAS2.ad.emulex.com>
References: <1397544352-28841-1-git-send-email-zhen-hual@hp.com>
 <b4855c2a-5a63-47a5-ba61-f9ce736f6401@CMEXHTCAS1.ad.emulex.com>
 <534CF596.3010609@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Subramanian Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <Ajit.Khaparde@Emulex.Com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Li, ZhenHua" <zhen-hual@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <534CF596.3010609@hp.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Li, ZhenHua [mailto:zhen-hual@hp.com]
> 
> Because netif_running() is called in netif_device_detach and
> netif_device_attach. To avoid dev status changed while
> netif_device_detach/attach is not finished, I think a rtnl_lock and
> unlock should be called to avoid this.

Ok. I'd like to then factor the code slightly differently by using
routines like this:

be_close_sync() {
	rtnl_lock();

  	netif_device_detach(netdev);
   	if (netif_running(netdev))
   		be_close(netdev);

	rtnl_unlock();
}

and similarly for be_open_sync()

And, I'd need some time to test these flows too.
Would you be OK with this?

thanks,
-Sathya
