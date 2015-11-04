From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v5] i40e: Look up MAC address in Open Firmware or IDPROM
Date: Wed, 4 Nov 2015 15:06:31 -0500
Message-ID: <20151104200631.GG14575@oracle.com>
References: <20151104193956.GD14575@oracle.com>
 <CAHp75Vcrx+Rkz2mDSG+GEUW6LdO0w6On=6UoV4fhZK27Ayf1zQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: intel-wired-lan@lists.osuosl.org, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHp75Vcrx+Rkz2mDSG+GEUW6LdO0w6On=6UoV4fhZK27Ayf1zQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (11/04/15 21:59), Andy Shevchenko wrote:
> 
> Usually the structure of kernel doc is something like following
> 
> /**
>  * func - summary
>  * @paramx: desc
>  *
>  * Description:
>  * Long description in many lines and / or paragraphs
>  *
>  * Returns:
>  * 0 on success or errno otherwise.
>  */
> 
> 
> > + **/
> 
> No need two stars.

I was actually following the exact comment style of 
the function just before i40e_macaddr_init, namely:;

/**
 * i40e_vsi_setup - Set up a VSI by a given type
 * @pf: board private structure
 * @type: VSI type
 * @uplink_seid: the switch element to link to
 * @param1: usage depends upon VSI type. For VF types, indicates VF id
 *
 * This allocates the sw VSI structure and its queue resources, then add a VSI
 * to the identified VEB.
 *
 * Returns pointer to the successfully allocated and configure VSI sw struct on
 * success, otherwise returns NULL on failure.
 **/
struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
                                u16 uplink_seid, u32 param1)

So I'm not sure we need to really bike-shed this one?
> > +                                       macaddr, NULL);
> > +       if (ret) {
> > +               dev_info(&vsi->back->pdev->dev,
> > +                        "Addr change for VSI failed: %d\n", ret);
> 
> dev_err() or dev_warn() I would say.

again, this was a cut/paste of code from i40e_set_mac()
which does netdev_info.

> > +       ret = i40e_aq_add_macvlan(&vsi->back->hw, vsi->seid, &element, 1, NULL);
> > +       aq_err = vsi->back->hw.aq.asq_last_status;
> 
> Do you really need a separate variable (aq_err)?

That seems to be the convention used elsewhere, where ret is
distinguished from aq_err, see i40e_sync_vsi_filters()

> > +       if (aq_err != I40E_AQ_RC_OK) {
> > +               dev_info(&vsi->back->pdev->dev,
> > +                        "add filter failed err %s aq_err %s\n",
> > +                        i40e_stat_str(&vsi->back->hw, ret),
> > +                        i40e_aq_str(&vsi->back->hw, aq_err));
> > +       }
> > +       return ret;

> Same about kernel doc.
See earlier response.

--Sowmini
