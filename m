From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH 1/1] ixgbevf: avoid checking hang when
 performing hardware reset
Date: Wed, 20 Jul 2016 10:42:33 +0800
Message-ID: <CAD=hENd98UENTqauL4R2OWj3533PNOcFO3LC7xJtaoZJ7a0hkA@mail.gmail.com>
References: <1468849489-8407-1-git-send-email-zyjzyj2000@gmail.com>
	<F6FB0E698C9B3143BDF729DF2228664696ACAA19@ORSMSX116.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3570601549025193937=="
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <F6FB0E698C9B3143BDF729DF2228664696ACAA19@ORSMSX116.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============3570601549025193937==
Content-Type: multipart/alternative; boundary=001a113ef3a25385d005380827b6

--001a113ef3a25385d005380827b6
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi=EF=BC=8C Don

I use a state variable to replace reading directly from the register. I
hope it can alleviate your concern. Please  comment.
Sorry. My mail service can not work well with netdev maillist. So I write
this mail to make sure that you can read this patch.

If any problem, please feel free to let me know.

Zhu Yanjun

On Tue, Jul 19, 2016 at 6:30 AM, Skidmore, Donald C <
donald.c.skidmore@intel.com> wrote:

> > -----Original Message-----
> > From: zyjzyj2000@gmail.com [mailto:zyjzyj2000@gmail.com]
> > Sent: Monday, July 18, 2016 6:45 AM
> > To: e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org; Kirsher,
> > Jeffrey T <jeffrey.t.kirsher@intel.com>
> > Subject: [E1000-devel] [PATCH 1/1] ixgbevf: avoid checking hang when
> > performing hardware reset
> >
> > From: Zhu Yanjun <zyjzyj2000@gmail.com>
> >
> > When performing hardware reset, it is not necessary to check hang.
> > Or else, the call trace will appear.
> >
> > Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
> > ---
> >  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 5 +++++
> >  1 file changed, 5 insertions(+)
> >
> > diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> > b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> > index acc2401..d563d24 100644
> > --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> > +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> > @@ -2792,9 +2792,14 @@ static void ixgbevf_reset_subtask(struct
> > ixgbevf_adapter *adapter)  static void ixgbevf_check_hang_subtask(struc=
t
> > ixgbevf_adapter *adapter)  {
> >       struct ixgbe_hw *hw =3D &adapter->hw;
> > +     struct ixgbe_mbx_info *mbx =3D &hw->mbx;
> >       u32 eics =3D 0;
> >       int i;
> >
> > +     /* When performing hardware reset, unnecessary to check hang. */
> > +     if (mbx->ops.check_for_rst(hw))
> > +             return;
> > +
> >       /* If we're down or resetting, just bail */
> >       if (test_bit(__IXGBEVF_DOWN, &adapter->state) ||
> >           test_bit(__IXGBEVF_RESETTING, &adapter->state))
> > --
> > 2.7.4
> >
> >
>
> My concern with this patch is that the check_for_rst does a read to clear
> on the RSTD and RSTI bits.  So reading it in the service task may mean we
> miss this transition in the mailbox protocol.  Likewise it is possible th=
ey
> may have already been cleared and you won't even catch the state your
> looking for.
>
> -Don Skidmore <donald.c.skidmore@intel.com>
>
>
>

--001a113ef3a25385d005380827b6--


--===============3570601549025193937==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
What NetFlow Analyzer can do for you? Monitors network bandwidth and traffic
patterns at an interface-level. Reveals which users, apps, and protocols are 
consuming the most bandwidth. Provides multi-vendor support for NetFlow, 
J-Flow, sFlow and other flows. Make informed decisions using capacity planning
reports.http://sdm.link/zohodev2dev
--===============3570601549025193937==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============3570601549025193937==--
