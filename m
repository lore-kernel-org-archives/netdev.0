From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH v2 1/9] drivers: net: Remove unused function
 igb_get_eee_status_i354() in e1000_82575.c
Date: Mon, 16 Dec 2013 09:43:12 -0800
Message-ID: <20131216174312.GA26982@jtriplet-mobl1>
References: <a610f6ee6bb992b91e43bdc851f3db62fc3decd5.1386911123.git.rashika.kheria@gmail.com>
 <9BBC4E0CF881AA4299206E2E1412B6264FA1408B@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rashika Kheria <rashika.kheria@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Dave, Tushar N" <tushar.n.dave@intel.com>,
	"Abodunrin, Akeem G" <akeem.g.abodunrin@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9BBC4E0CF881AA4299206E2E1412B6264FA1408B@ORSMSX102.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 16, 2013 at 05:11:25PM +0000, Wyborny, Carolyn wrote:
> > -----Original Message-----
> > From: Rashika Kheria [mailto:rashika.kheria@gmail.com]
> > Sent: Saturday, December 14, 2013 4:15 AM
> > To: linux-kernel@vger.kernel.org
> > Cc: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W; Wyborny,=
 Carolyn;
> > Skidmore, Donald C; Rose, Gregory V; Waskiewicz Jr, Peter P; Duyck,=
 Alexander
> > H; Ronciak, John; Dave, Tushar N; Abodunrin, Akeem G; Vick, Matthew=
; e1000-
> > devel@lists.sourceforge.net; netdev@vger.kernel.org; josh@joshtripl=
ett.org
> > Subject: [PATCH v2 1/9] drivers: net: Remove unused function
> > igb_get_eee_status_i354() in e1000_82575.c
> >=20
> > This patch removes the function igb_get_eee_status_i354() in e1000_=
82575.c
> > because it is unused.
> >=20
> > It thus eliminates the following warning in
> > ethernet/intel/igb/e1000_82575.c:
> > drivers/net/ethernet/intel/igb/e1000_82575.c:2591:5: warning: no pr=
evious
> > prototype for =E2=80=98igb_get_eee_status_i354=E2=80=99 [-Wmissing-=
prototypes]
> >=20
> > Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
> > Reviewed-by: Josh Triplett <josh@joshtriplett.org>
> > ---
> >  drivers/net/ethernet/intel/igb/e1000_82575.c |   32 --------------=
------------
> >  1 file changed, 32 deletions(-)
> >=20
> > diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c
> > b/drivers/net/ethernet/intel/igb/e1000_82575.c
> > index 47c2d10..18e5200 100644
> > --- a/drivers/net/ethernet/intel/igb/e1000_82575.c
> > +++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
> > @@ -2580,38 +2580,6 @@ out:
> >  	return ret_val;
> >  }
> >=20
> > -/**
> > - *  igb_get_eee_status_i354 - Get EEE status
> > - *  @hw: pointer to the HW structure
> > - *  @status: EEE status
> > - *
> > - *  Get EEE status by guessing based on whether Tx or Rx LPI indic=
ations have
> > - *  been received.
> > - **/
> > -s32 igb_get_eee_status_i354(struct e1000_hw *hw, bool *status) -{
> > -	struct e1000_phy_info *phy =3D &hw->phy;
> > -	s32 ret_val =3D 0;
> > -	u16 phy_data;
> > -
> > -	/* Check if EEE is supported on this device. */
> > -	if ((hw->phy.media_type !=3D e1000_media_type_copper) ||
> > -	    (phy->id !=3D M88E1543_E_PHY_ID))
> > -		goto out;
> > -
> > -	ret_val =3D igb_read_xmdio_reg(hw, E1000_PCS_STATUS_ADDR_I354,
> > -				     E1000_PCS_STATUS_DEV_I354,
> > -				     &phy_data);
> > -	if (ret_val)
> > -		goto out;
> > -
> > -	*status =3D phy_data & (E1000_PCS_STATUS_TX_LPI_RCVD |
> > -			      E1000_PCS_STATUS_RX_LPI_RCVD) ? true : false;
> > -
> > -out:
> > -	return ret_val;
> > -}
> > -
> >  static const u8 e1000_emc_temp_data[4] =3D {
> >  	E1000_EMC_INTERNAL_DATA,
> >  	E1000_EMC_DIODE1_DATA,
> > --
> > 1.7.9.5
>=20
> NACK.
>=20
> Thanks for the patch Rashika, but this is the incorrect fix for this
> warning  The function is called in the igb_probe function, so you
> cannot remove it and I see the prototype in the e1000_82575.h file.
> Can you double check your source pull?

=46rom top-of-tree linux.git:

~/src/linux$ git grep igb_get_eee_status_i354
drivers/net/ethernet/intel/igb/e1000_82575.c: *  igb_get_eee_status_i35=
4 - Get EEE status
drivers/net/ethernet/intel/igb/e1000_82575.c:s32 igb_get_eee_status_i35=
4(struct e1000_hw *hw, bool *status)

A comment and the function itself; no other references.  In what tree
are you seeing a reference to igb_get_eee_status_i354?

- Josh Triplett
