From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [RFC,v3,12/12] fsl/fman: Add FMan MAC driver
Date: Tue, 21 Jul 2015 13:44:59 +0000
Message-ID: <1437486300.10831.42.camel@transmode.se>
References: <1430299742-29428-1-git-send-email-igal.liberman@freescale.com>
	 <1437394575.10831.18.camel@transmode.se>
	 <BL2PR03MB5450DB021D160D507432FC5E6850@BL2PR03MB545.namprd03.prod.outlook.com>
	 <1437397042.10831.34.camel@transmode.se>
	 <BL2PR03MB545971A75540877E4B4FFD3E6850@BL2PR03MB545.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Igal.Liberman@freescale.com" <Igal.Liberman@freescale.com>,
	"madalin.bucur@freescale.com" <madalin.bucur@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BL2PR03MB545971A75540877E4B4FFD3E6850@BL2PR03MB545.namprd03.prod.outlook.com>
Content-Language: en-US
Content-ID: <89B35F31E581C74EA1D4C840E5A158C7@transmode.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-07-20 at 13:33 +0000, Madalin-Cristian Bucur wrote:
> > -----Original Message-----
> > From: Joakim Tjernlund [mailto:joakim.tjernlund@transmode.se]
> > Sent: Monday, July 20, 2015 3:57 PM
> > To: netdev@vger.kernel.org; Liberman Igal-B31950; Bucur Madalin-Cristian-
> > B32716
> > Cc: linuxppc-dev@lists.ozlabs.org; linux-kernel@vger.kernel.org
> > Subject: Re: [RFC,v3,12/12] fsl/fman: Add FMan MAC driver
> > 
> > On Mon, 2015-07-20 at 12:28 +0000, Madalin-Cristian Bucur wrote:
> > > Hi Joakim,
> > > 
> > > It seems we just need to align to the API introduced by Thomas Petazzoni
> > > in 3be2a49e.
> > > 
> > > Madalin
> > 
> > So it seems, any idea when the next spin will be ready?
> > Could you also push it onto
> >   http://git.freescale.com/git/cgit.cgi/ppc/upstream/linux.git/
> > ?
> > 
> >  Jocke
> 
> We're working on addressing all the feedback received to date (you've just added
> a bit more) then we'll re-submit the FMan driver together with the DPAA Ethernet
> driver. A push in the public git is also going to take place after the patches are sent
> for review.

Hi again

Now I got to actually use PHY less(aka. Fixed PHY) too. I had to hack AN off for all such links
to get a 1000 SGMII link working:
--- a/drivers/net/ethernet/freescale/fman/mac/memac.c
+++ b/drivers/net/ethernet/freescale/fman/mac/memac.c
@@ -80,7 +80,10 @@ static void setup_sgmii_internal_phy(struct memac_t *p_memac, uint8_t phy_addr)
                           ENET_SPEED_1000);
 
        /* SGMII mode + AN enable */
-       tmp_reg16 = PHY_SGMII_IF_MODE_AN | PHY_SGMII_IF_MODE_SGMII;
+       //tmp_reg16 = PHY_SGMII_IF_MODE_AN | PHY_SGMII_IF_MODE_SGMII;
+       tmp_reg16 = PHY_SGMII_IF_MODE_AN | PHY_SGMII_IF_MODE_SGMII | 0x8;
+       if (p_memac->mac_id != 0)
+               tmp_reg16 &= ~PHY_SGMII_IF_MODE_AN;
        memac_mii_write_phy_reg(p_memac, phy_addr, 0x14, tmp_reg16);
 
        /* Device ability according to SGMII specification */
@@ -104,6 +107,8 @@ static void setup_sgmii_internal_phy(struct memac_t *p_memac, uint8_t phy_addr)
 
        /* Restart AN */
        tmp_reg16 = PHY_SGMII_CR_DEF_VAL | PHY_SGMII_CR_RESET_AN;
+       if (p_memac->mac_id != 0)
+               tmp_reg16 &= ~0x1000;
        memac_mii_write_phy_reg(p_memac, phy_addr, 0x0, tmp_reg16);
 
        /* Restore original enet mode */


Could you please fix this too?

 Jocke