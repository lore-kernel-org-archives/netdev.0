From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH] stmmac: fix memory barriers
Date: Mon, 19 Dec 2016 17:10:17 +0000
Message-ID: <79efbe1a-bdc3-2aca-88a2-42a1b29f292d@synopsys.com>
References: <20161218203812.GA1012@amd>
 <20161219.110655.448567935176535028.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <LinoSanfilippo@gmx.de>, <peppe.cavallaro@st.com>,
        <alexandre.torgue@st.com>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>, <niklas.cassel@axis.com>,
        <Joao.Pinto@synopsys.com>
To: David Miller <davem@davemloft.net>, <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161219.110655.448567935176535028.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am trying to built net-next git tree and it is failing:

  CC      drivers/pnp/card.o
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c: In function
‘stmmac_hw_fix_mac_speed’:
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:224:34: error: ‘struct
stmmac_priv’ has no member named ‘phydev’
  struct phy_device *phydev = priv->phydev;
                                  ^
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c: In function ‘stmmac_eee_init’:
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:298:24: error: ‘struct
stmmac_priv’ has no member named ‘phydev’
   if (phy_init_eee(priv->phydev, 1)) {
                        ^
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:330:44: error: ‘struct
stmmac_priv’ has no member named ‘phydev’
   priv->hw->mac->set_eee_pls(priv->hw, priv->phydev->link);
                                            ^
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c: In function ‘stmmac_init_ptp’:
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:672:2: error: void value not
ignored as it ought to be
  return stmmac_ptp_register(priv);
  ^
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c: In function ‘stmmac_adjust_link’:
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:694:34: error: ‘struct
stmmac_priv’ has no member named ‘phydev’
  struct phy_device *phydev = priv->phydev;
                                  ^
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c: In function ‘stmmac_init_phy’:
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:884:6: error: ‘struct
stmmac_priv’ has no member named ‘phydev’
  priv->phydev = phydev;
      ^
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c: In function ‘stmmac_open’:
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1810:10: error: ‘struct
stmmac_priv’ has no member named ‘phydev’
  if (priv->phydev)
          ^
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1811:17: error: ‘struct
stmmac_priv’ has no member named ‘phydev’
   phy_start(priv->phydev);
                 ^
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1858:10: error: ‘struct
stmmac_priv’ has no member named ‘phydev’
  if (priv->phydev)
          ^
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1859:22: error: ‘struct
stmmac_priv’ has no member named ‘phydev’
   phy_disconnect(priv->phydev);
                      ^
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c: In function ‘stmmac_release’:
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1878:10: error: ‘struct
stmmac_priv’ has no member named ‘phydev’
  if (priv->phydev) {
          ^
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1879:16: error: ‘struct
stmmac_priv’ has no member named ‘phydev’
   phy_stop(priv->phydev);
                ^
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1880:22: error: ‘struct
stmmac_priv’ has no member named ‘phydev’
   phy_disconnect(priv->phydev);
                      ^
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1881:7: error: ‘struct
stmmac_priv’ has no member named ‘phydev’
   priv->phydev = NULL;
       ^
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c: In function ‘stmmac_ioctl’:
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:2883:12: error: ‘struct
stmmac_priv’ has no member named ‘phydev’
   if (!priv->phydev)
            ^
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:2885:27: error: ‘struct
stmmac_priv’ has no member named ‘phydev’
   ret = phy_mii_ioctl(priv->phydev, rq, cmd);
                           ^
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c: In function ‘stmmac_suspend’:
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:3438:10: error: ‘struct
stmmac_priv’ has no member named ‘phydev’
  if (priv->phydev)
          ^
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:3439:16: error: ‘struct
stmmac_priv’ has no member named ‘phydev’
   phy_stop(priv->phydev);
                ^
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c: In function ‘stmmac_resume’:
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:3533:10: error: ‘struct
stmmac_priv’ has no member named ‘phydev’
  if (priv->phydev)
          ^
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:3534:17: error: ‘struct
stmmac_priv’ has no member named ‘phydev’
   phy_start(priv->phydev);
                 ^
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c: In function ‘stmmac_init_ptp’:
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:673:1: warning: control
reaches end of non-void function [-Wreturn-type]
 }
 ^
  CC      drivers/pnp/driver.o
make[5]: *** [drivers/net/ethernet/stmicro/stmmac/stmmac_main.o] Error 1
make[4]: *** [drivers/net/ethernet/stmicro/stmmac] Error 2
make[3]: *** [drivers/net/ethernet/stmicro] Error 2
make[3]: *** Waiting for unfinished jobs....
  CC      drivers/pnp/resource.o

Thanks,
Joao

Às 4:06 PM de 12/19/2016, David Miller escreveu:
> From: Pavel Machek <pavel@ucw.cz>
> Date: Sun, 18 Dec 2016 21:38:12 +0100
> 
>> Fix up memory barriers in stmmac driver. They are meant to protect
>> against DMA engine, so smp_ variants are certainly wrong, and dma_
>> variants are preferable.
>>     
>> Signed-off-by: Pavel Machek <pavel@denx.de>
> 
> Applied.
> 
