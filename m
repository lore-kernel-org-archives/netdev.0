From: "Asgeir Eiriksson" <asgeir@chelsio.com>
Subject: RE: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit ProposedTopics
Date: Mon, 28 Mar 2005 16:44:08 -0800
Message-ID: <67D69596DDF0C2448DB0F0547D0F947E01781DEF@yogi.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, <mpm@selenic.com>,
        <andrea@suse.de>, <michaelc@cs.wisc.edu>,
        <James.Bottomley@HansenPartnership.com>,
        <ksummit-2005-discuss@thunk.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Dmitry Yusupov" <dmitry_yus@yahoo.com>, <open-iscsi@googlegroups.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com] On
> Behalf Of Dmitry Yusupov
> Sent: Monday, March 28, 2005 12:49 PM
> To: open-iscsi@googlegroups.com
> Cc: David S. Miller; mpm@selenic.com; andrea@suse.de;
> michaelc@cs.wisc.edu; James.Bottomley@HansenPartnership.com;
ksummit-2005-
> discuss@thunk.org; netdev@oss.sgi.com
> Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit
> ProposedTopics
> 
> Basically, HW offloading all kind of is a different subject.
> Yes, iSER/RDMA/RNIC will help to avoid bunch of problems but at the
same
> time will add bunch of new problems. OOM/deadlock problem we are
> discussing is a software, *not* hardware related.
> 
> If you have plans to start new project such as SoftRDMA than yes. lets
> discuss it since set of problems will be similar to what we've got
with
> software iSCSI Initiators.
> 
> I'm not a believer in any HW state-full protocol offloading
technologies
> and that was one of my motivations to initiate Open-iSCSI project to
> prove that performance is not an issue anymore. And we succeeded, by
> showing comparable to iSCSI HW Initiator's numbers.
> 

Dmitry

Care to be more specific about the performance you achieved?

You might want to contrast your numbers to veritest verified numbers of
800+ MBps and 600+KOPS achieved by Chelsio HBA with stateful offload
using either 1500B or 9KB MTU (for full detail see Veritest report at
http://www.chelsio.com/technology/Chelsio10GbE_iSCSI_report.pdf)

'Asgeir

> Though, for me, RDMA over TCP is an interesting topic from software
> implementation point of view. I was thinking about organizing new
> project. If someone knows that related work is already started - let
me
> know since I might be interested to help.
> 
> Dmitry
> 
> On Mon, 2005-03-28 at 11:45 -0800, Roland Dreier wrote:
> > Let me slightly hijack this thread to throw out another topic that I
> > think is worth talking about at the kernel summit: handling remote
DMA
> > (RDMA) network technologies.
> >
> > As some of you might know, I'm one of the main authors of the
> > InfiniBand support in the kernel, and I think we have things fairly
> > well in hand there, although handling direct userspace access to
RDMA
> > capabilities may raise some issues worth talking about.
> >
> > However, there is also RDMA-over-TCP hardware beginning to be used,
> > based on the specs from the IETF rddp working group and the RDMA
> > Consortium.  I would hope that we can abstract out the common pieces
> > for InfiniBand and RDMA NIC (RNIC) support and morph
> > drivers/infiniband into a more general drivers/rdma.
> >
> > This is not _that_ offtopic, since RDMA NICs provide another way of
> > handling OOM for iSCSI.  By having the NIC handle the network
> > transport through something like iSER, you avoid a lot of the issues
> > in this thread.  Having to reconnect to a target while OOM is still
a
> > problem, but it seems no worse in principal than the issues with a
> > dump FC card that needs the host driver to handling fabric login.
> >
> > I know that in the InfiniBand world, people have been able to run
> > stress tests of storage over SCSI RDMA Protocol (SRP) with very
heavy
> > swapping going on and no deadlocks.  SRP is in effect network
storage
> > with the transport handled by the IB hardware.
> >
> > However there are some sticky points that I would be interested in
> > discussing.  For example, the IETF rddp drafts envisage what they
call
> > a "dual stack" model: TCP connections are set up by the usual
network
> > stack and run for a while in "streaming" mode until the application
is
> > ready to start using RDMA.  At that point there is an "MPA"
> > negotiation and then the socket is handed over to the RNIC.  Clearly
> > moving the state from the kernel's stack to the RNIC is not trivial.
> >
> > Other developers who have more direct experience with RNIC hardware
or
> > perhaps just strong opinions may have other things in this area that
> > they'd like to talk about.
> >
> > Thanks,
> >   Roland
> 
