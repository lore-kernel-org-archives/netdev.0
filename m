From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [Intel-wired-lan] [PATCH v6] i40e: Look up MAC address in Open
 Firmware or IDPROM
Date: Thu, 3 Dec 2015 11:58:50 -0500
Message-ID: <20151203165850.GB15262@oracle.com>
References: <20151105.103126.148818796422971143.davem@davemloft.net>
 <20151105.110506.1901401372160830603.davem@davemloft.net>
 <CAHp75VfiV6DVb-2piCxmEWFP4Gi-+n0qNhhscvd=UsqXrivVYg@mail.gmail.com>
 <20151105.133131.1900833527415923596.davem@davemloft.net>
 <CAHp75Ve2sLrNZGjD=1LHbyzQEuB2GMhXJxmBgQo1Y4eCHzPk+A@mail.gmail.com>
 <26D9FDECA4FBDD4AADA65D8E2FC68A4A0F96CBB6@ORSMSX104.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>,
	David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	netdev <netdev@vger.kernel.org>
To: "Bowers, AndrewX" <andrewx.bowers@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <26D9FDECA4FBDD4AADA65D8E2FC68A4A0F96CBB6@ORSMSX104.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (12/03/15 16:53), Bowers, AndrewX wrote:

> 
> I get an error -11 on driver init with this patch applied, I can
> revert it and everything works normally. Dmesg screenshot is attached,
> can supply complete dmesg log if needed.

Yes, that's the same thing that I'm running into as well. 
Using this patch makes this work. But this adds some ugly
ifdef's, and other methods should be explored.

--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9102,9 +9102,11 @@ struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 ty
                ret = i40e_config_netdev(vsi);
                if (ret)
                        goto err_netdev;
+#if defined(CONFIG_SPARC) || defined(CONFIG_OF)
                ret = i40e_macaddr_init(vsi, pf->hw.mac.addr);
                if (ret)
                        goto err_netdev;
+#endif
                ret = register_netdev(vsi->netdev);
                if (ret)
                        goto err_netdev;
