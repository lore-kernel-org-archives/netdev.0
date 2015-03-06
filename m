From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: Re: [PATCH v2] ixgbe: make VLAN filter conditional
Date: Fri, 6 Mar 2015 09:46:41 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05E4F392@BPXM14GP.gisp.nec.co.jp>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E4EC48@BPXM14GP.gisp.nec.co.jp>
	<1425634456.2556.160.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Choi,
	Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1425634456.2556.160.camel@jtkirshe-mobl>
Content-Language: ja-JP
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> On Fri, 2015-03-06 at 06:04 +0000, Hiroshi Shimamoto wrote:
> > > From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> > >
> > > Disable hardware VLAN filtering if netdev->features VLAN flag is
> > dropped.
> > >
> > > In SR-IOV case, there is a use case which needs to disable VLAN
> > filter.
> > > For example, we need to make a network function with VF in
> > virtualized
> > > environment. That network function may be a software switch, a
> > router
> > > or etc. It means that that network function will be an end point
> > which
> > > terminates many VLANs.
> > >
> > > In the current implementation, VLAN filtering always be turned on
> > and
> > > VF can receive only 63 VLANs. It means that only 63 VLANs can be
> > terminated
> > > in one NIC.
> > >
> > > With this patch, if the user turns VLAN filtering off on the host,
> > VF
> > > can receive every VLAN packet.
> > >
> > > This VLAN filtering can be turned on or off when SR-IOV is disabled,
> > if not
> > > the operation is rejected.
> >
> > Hi,
> >
> > any comment about this?
> > I added a warning message and prevent operation during SR-IOV is
> > enabled.
> 
> Yes, the warning message you added says nothing of the huge security
> hole this exposes.  We need a message the correctly expresses the
> dangers in turning this off.

hm okay.
Do you mean I should add a message like "this causes SECURITY issue", right?

> 
> Also it does not appear that you addressed Ben Hutchings concerns, as I
> asked.  Correct me if I am wrong and you did address Ben's concerns.

I think Ben's suggestion is to prevent turn VLAN filtering back on during
VFs are used because that breaks guest's behavior.
I added the code that make it impossible. We cannot turn on (or off) if
the NIC has VFs.

thanks,
Hiroshi
------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
