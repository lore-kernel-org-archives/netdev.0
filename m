From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH 1/1] ixgbevf: replace enum with MACROs
Date: Thu, 21 Jul 2016 17:53:06 +0800
Message-ID: <CAD=hENf70skR=9a5JXbGtHJeg2MEv=DTgBgD_tbMEBz+hV7HPQ@mail.gmail.com>
References: <1469011313-30044-1-git-send-email-zyjzyj2000@gmail.com>
	<1469011313-30044-2-git-send-email-zyjzyj2000@gmail.com>
	<CAKgT0UefaX0aqV+mC77zrpWZAQWBKygDCG0Bpq0x2sVyeMpyYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4086812283163683137=="
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CAKgT0UefaX0aqV+mC77zrpWZAQWBKygDCG0Bpq0x2sVyeMpyYw@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============4086812283163683137==
Content-Type: multipart/alternative; boundary=001a11c17488f0d028053822483c

--001a11c17488f0d028053822483c
Content-Type: text/plain; charset=UTF-8

Got it. Thanks a lot.

Zhu Yanjun

On Wed, Jul 20, 2016 at 10:29 PM, Alexander Duyck <alexander.duyck@gmail.com
> wrote:

> On Wed, Jul 20, 2016 at 3:41 AM,  <zyjzyj2000@gmail.com> wrote:
> > From: Zhu Yanjun <zyjzyj2000@gmail.com>
> >
> > With the original enum, when a several bits state is set, it is
> > possible that the wrong test occurs.
> >
> > For example,
> >
> > a state is 0x3, its bits are 11. When testing a state 0x2 whose
> > bits are 10, it is difficult to confirm that state 0x2 is set or
> > not.
> >
> > As such, the MACROs are defined to avoid the above error.
> >
> > Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
> > ---
> >  drivers/net/ethernet/intel/ixgbevf/ixgbevf.h | 22 ++++++++++------------
> >  1 file changed, 10 insertions(+), 12 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> > index 60fc63b..d37b910 100644
> > --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> > +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> > @@ -436,18 +436,16 @@ struct ixgbevf_adapter {
> >         u8 rss_indir_tbl[IXGBEVF_X550_VFRETA_SIZE];
> >  };
> >
> > -enum ixbgevf_state_t {
> > -       __IXGBEVF_TESTING,
> > -       __IXGBEVF_RESETTING,
> > -       __IXGBEVF_DOWN,
> > -       __IXGBEVF_DISABLED,
> > -       __IXGBEVF_REMOVING,
> > -       __IXGBEVF_SERVICE_SCHED,
> > -       __IXGBEVF_SERVICE_INITED,
> > -       __IXGBEVF_RESET_REQUESTED,
> > -       __IXGBEVF_QUEUE_RESET_REQUESTED,
> > -       __IXGBEVF_HW_RESETTING,
> > -};
> > +#define        __IXGBEVF_TESTING               0x0001
> > +#define        __IXGBEVF_RESETTING             0x0002
> > +#define        __IXGBEVF_DOWN                  0x0004
> > +#define        __IXGBEVF_DISABLED              0x0008
> > +#define        __IXGBEVF_REMOVING              0x0010
> > +#define        __IXGBEVF_SERVICE_SCHED         0x0020
> > +#define        __IXGBEVF_SERVICE_INITED        0x0040
> > +#define        __IXGBEVF_RESET_REQUESTED       0x0080
> > +#define        __IXGBEVF_QUEUE_RESET_REQUESTED 0x0100
> > +#define        __IXGBEVF_HW_RESETTING          0x0200
> >
> >  enum ixgbevf_boards {
> >         board_82599_vf,
>
> You cannot replace a bit offset with a mask without also having to
> update all the spots where the bit offset is used.
>
> There isn't much point to replacing the enum with a macro anyway.
> Using multiple test_bit expressions should be valid for testing
> multiple bits.
>
> - Alex
>

--001a11c17488f0d028053822483c--


--===============4086812283163683137==
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
--===============4086812283163683137==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============4086812283163683137==--
