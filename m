From: Dmitry Yusupov <dmitry_yus@yahoo.com>
Subject: Re: Linux support for RDMA (was: [Ksummit-2005-discuss] Summary of
	2005 Kernel Summit Proposed Topics)
Date: Sun, 03 Apr 2005 17:56:11 -0700
Message-ID: <1112576171.4227.5.camel@mylaptop>
References: <67D69596DDF0C2448DB0F0547D0F947E01781F2E@yogi.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, mpm@selenic.com, andrea@suse.de,
        michaelc@cs.wisc.edu, James.Bottomley@HansenPartnership.com,
        ksummit-2005-discuss@thunk.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "open-iscsi@googlegroups.com" <open-iscsi@googlegroups.com>
In-Reply-To: <67D69596DDF0C2448DB0F0547D0F947E01781F2E@yogi.asicdesigners.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-04-02 at 11:07 -0800, Asgeir Eiriksson wrote:
> Dmitry

> The CPU cycles is only at most half of the story with the other half
> being the memory sub-system BW.
> 
> So the validity of your observation depends on the BW we're talking
> about, i.e. if the client is using a fraction of 10Gbps for RDMA (or
> DDP, e.g. iSCSI DDP), yes then that fraction amounts to a fraction of
> the memory sub-system total BW so we don't much care about the extra
> copy.
> 
> The situation is different if the client wants something close to 10Gbps
> (already have such client applications), because today 10Gbps is still a
> big chunk of the overall memory BW so you really care about eliminating
> that copy via DDP.

I do not get your concern with memory BW. With good AMD box V40Z(SUN)
you can get 5.3GBytes/sec. Even with 10Gbps full speed you have 80%
left. PCI-X BUS BW is bigger concern...

> 'Asgeir
> 
> > -----Original Message-----
> > From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com] On
> > Behalf Of Dmitry Yusupov
> > Sent: Saturday, April 02, 2005 10:09 AM
> > To: open-iscsi@googlegroups.com
> > Cc: David S. Miller; mpm@selenic.com; andrea@suse.de;
> > michaelc@cs.wisc.edu; James.Bottomley@HansenPartnership.com;
> ksummit-2005-
> > discuss@thunk.org; netdev@oss.sgi.com
> > Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit
> > ProposedTopics
> > 
> > On Mon, 2005-03-28 at 17:32 -0500, Benjamin LaHaise wrote:
> > > On Mon, Mar 28, 2005 at 12:48:56PM -0800, Dmitry Yusupov wrote:
> > > > If you have plans to start new project such as SoftRDMA than yes.
> lets
> > > > discuss it since set of problems will be similar to what we've got
> > with
> > > > software iSCSI Initiators.
> > >
> > > I'm somewhat interested in seeing a SoftRDMA project get off the
> ground.
> > > At least the NatSemi 83820 gige MAC is able to provide early-rx
> > interrupts
> > > that allow one to get an rx interrupt before the full payload has
> > arrived
> > > making it possible to write out a new rx descriptor to place the
> payload
> > > wherever it is ultimately desired.  It would be fun to work on if
> not
> > the
> > > most performant RDMA implementation.
> > 
> > I see a lot of skepticism around early-rx interrupt schema. It might
> > work for gige, but i'm not sure if it will fit into 10g.
> > 
> > What RDMA gives us is zero-copy on receive and new networking api
> which
> > has a potential to be HW accelerated. SoftRDMA will never avoid
> copying
> > on receive. But benefit for SoftRDMA would be its availability on
> client
> > sides. It is free and it could be easily deployed. Soon Intel & Co
> will
> > give us 2,4,8... multi-core CPUs for around 200$ :), So, who cares if
> > one of those cores will do receive side copying?
> > 
> 
> 
