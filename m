From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Linux support for RDMA (was: [Ksummit-2005-discuss] Summary of
 2005 Kernel Summit Proposed Topics)
Date: Mon, 4 Apr 2005 09:50:47 -0700
Message-ID: <20050404095047.4d5c263f@dxpl.pdx.osdl.net>
References: <1112405833.424df749e61b5@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland@topspin.com>, Benjamin LaHaise <bcrl@kvack.org>,
        Dmitry Yusupov <dmitry_yus@yahoo.com>, open-iscsi@googlegroups.com,
        "David
  S. Miller" <davem@davemloft.net>, mpm@selenic.com,
        andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com, bmt@zurich.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jaganav@us.ibm.com
In-Reply-To: <1112405833.424df749e61b5@imap.linux.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri,  1 Apr 2005 20:37:13 -0500
jaganav@us.ibm.com wrote:

> Quoting Stephen Hemminger <shemminger@osdl.org>:
> 
> > On Thu, 31 Mar 2005 21:13:39 -0500
> > jaganav@us.ibm.com wrote:
> > 
> > > Quoting Roland Dreier <roland@topspin.com>:
> > > > I have to admit I don't know much about the TOE / RDMA/TCP / RNIC (or
> > > > whatever you want to call it) world.  However I know that the large
> > > > majority of InfiniBand use right now is running on Linux, and I hope
> > > > the Linux community is willing to work with the IB community.
> > > >
> > > 
> > > Just want to let everyone know know that we have started an opensource
> > > effort (www.openrdma.org) for enablement of RNICs (RDMA enabled NICs).
> > This
> > > community has now come up with an architecture
> > > (http://rdma.sourceforge.net/architecture.pdf) to build this support in
> > Linux.
> > > Would really appreciate if you review and provide any comments. We have
> > just
> > > started to hack but no code is available on this project yet.
> > > 
> > > Thanks
> > > Venkat
> > 
> > OpenRdma is a misnomer, because as I read your architecture you are trying
> > to
> > create a "kernel abstraction layer" for closed source vendor RDMA drivers.
> > This will
> > never be accepted,  please go back to the drawing board and figure out how to
> > make
> > real open source drivers.
> > 
> > 
> 
> First let me say that the purpose of this project is to
> make the entire stack (with all of the enablement layers)
> including the drivers opensourced.

How about putting out code early that implements a subset of
what you want (and not waiting till you think it is done).

> The kernel abstraction layer will be built 
> around standards based (opengroup.org/icsc) RNIC-PI 
> interface and which allows the RNIC vendors to opensource
> their drivers using that interface. BTW, RNIC-PI
> interface is work-in-progress and the first draft
> is targeted to be published soon.

But standards based abstraction layer is sure to be limited to least common
denominator. The locking model and setup/teardown are sure to be different
under each OS.

Also, it is impossible to build any decent abstraction top-down in a "waterfall"
model. You need to have an iterative process that refines and is willing to have
compatibility restrictions. Also, the kernel community hates interfaces and code
where there is a big *don't go here* box that prevents fixing bugs and improving
interfaces.  Linux puts a big emphasis on long-term maintainability of code.
 
Another issue that concerns me is making sure that all the security and 
policy are maintained when doing RDMA.  How do you  do firewalling and
routing when you are allowing adapter to control the world?

> Several RNIC adapter vendors, who contribute to the 
> openRDMA effort, are quite willing to opensource 
> their drivers through openRDMA project.
> 
> BTW, I understood why you got the impression 
> that the this is for closed source vendor drivers:
> Our intention is not to allow the kernel verbs
> provider code (kVP) to be private and that was
> an error. Thanks for pointing this out
> but we'll make this change soon.

You are attacking a hard problem. Thanks for the effort.
