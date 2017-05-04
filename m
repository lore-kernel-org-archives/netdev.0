From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC iproute2 0/8] RDMA tool
Date: Thu, 04 May 2017 16:45:58 -0400
Message-ID: <1493930758.3041.231.camel@redhat.com>
References: <20170504180216.7665-1-leon@kernel.org>
         <1493921453.2692.6.camel@sandisk.com>
         <20170504182542.GD22833@mtr-leonro.local>
         <1493922625.2692.8.camel@sandisk.com>
         <20170504184531.GE22833@mtr-leonro.local>
         <2dee6cde-0406-b101-0fe6-c1f6de7c1b1a@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org" <ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org" <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>,
        "ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org" <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        "stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org" <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        "ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2dee6cde-0406-b101-0fe6-c1f6de7c1b1a-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-05-04 at 15:26 -0400, Dennis Dalessandro wrote:
> On 05/04/2017 02:45 PM, Leon Romanovsky wrote:
> > 
> > On Thu, May 04, 2017 at 06:30:27PM +0000, Bart Van Assche wrote:
> > > 
> > > On Thu, 2017-05-04 at 21:25 +0300, Leon Romanovsky wrote:
> > > > 
> > > > On Thu, May 04, 2017 at 06:10:54PM +0000, Bart Van Assche
> > > > wrote:
> > > > > 
> > > > > On Thu, 2017-05-04 at 21:02 +0300, Leon Romanovsky wrote:
> > > > > > 
> > > > > > Following our discussion both in mailing list [1] and at
> > > > > > the LPC 2016 [2],
> > > > > > we would like to propose this RDMA tool to be part of
> > > > > > iproute2 package
> > > > > > and finally improve this situation.
> > > > > 
> > > > > Hello Leon,
> > > > > 
> > > > > Although I really appreciate your work: can you clarify why
> > > > > you would like to
> > > > > add *RDMA* functionality to an *IP routing* tool? I haven't
> > > > > found any motivation
> > > > > for adding RDMA functionality to iproute2 in [1].
> > > > 
> > > > We are planning to reuse the same infrastructure provided by
> > > > iproute2,
> > > > like netlink parsing, access to distributions, same CLI and
> > > > same standards.
> > > > 
> > > > Right now, RDMA is already tightened to netdev: iWARP, RoCE,
> > > > IPoIB, HFI-VNIC.
> > > > Many drivers (mlx, qed, i40, cxgb) are sharing code between net
> > > > and
> > > > RDMA.
> > > > 
> > > > I do expect that iproute2 will be installed on every machine
> > > > with any
> > > > type of connection, including IB and OPA.
> > > > 
> > > > So I think that it is enough to be part of that suite and don't
> > > > invent
> > > > our own for one specific tool.
> > > 
> > > Hello Leon,
> > > 
> > > Sorry but to me that sounds like a weak argument for including
> > > RDMA functionality
> > > in iproute2. There is already a library for communication over
> > > netlink sockets,
> > > namely libnl. Is there functionality that is in iproute2 but not
> > > in libnl and
> > > that is needed for the new tool? If so, have you considered to
> > > create a new
> > > library for that functionality?
> > 
> > It is not hard to create new tool, the hardest part is to ensure
> > that it is
> > part of the distributions. Did you count how many months we are
> > trying to
> > add rdma-core to debian?
> 
> I do agree that it is a strange pairing and am not really a fan.
> However 
> at the end of the day it's just a name for a repo/package. If the 
> iproute folks are fine to include rdma in their repo/package, great
> we 
> can leverage their code for CLI and other common stuff.

If you look into the iproute2 package, it becomes clear that the name
iproute2 is historical and not really accurate any more.  It contains
things like the bridge control software, tc for controlling send
queues, and many things network related but not routing related.  The
rdma tool is a perfectly fine fit in the sense that it is an additional
network management tool IMO.

For reference, here's the list of stuff already in iproute on my Fedora
24 box:

/usr/sbin/arpd
/usr/sbin/bridge
/usr/sbin/cbq
/usr/sbin/ctstat
/usr/sbin/genl
/usr/sbin/ifcfg
/usr/sbin/ifstat
/usr/sbin/ip
/usr/sbin/lnstat
/usr/sbin/nstat
/usr/sbin/routef
/usr/sbin/routel
/usr/sbin/rtacct
/usr/sbin/rtmon
/usr/sbin/rtpr
/usr/sbin/rtstat
/usr/sbin/ss
/usr/sbin/tc
/usr/sbin/tipc

And in fact, if you check, tipc is almost similar to RDMA ;-)  So, I
suggest people not get hung up on the name iproute2, the fit is fine
when you look deeper into the nature of the package.

-- 
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
