From: Gerrit Huizenga <gh@us.ibm.com>
Subject: Re: Topic:  Remote DMA network technologies
Date: Mon, 28 Mar 2005 12:32:12 -0800
Message-ID: <E1DG0uC-0004vM-00@w-gerrit.beaverton.ibm.com>
References: <52vf7bwo4w.fsf@topspin.com>
Reply-To: Gerrit Huizenga <gh@us.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Dmitry Yusupov <dmitry_yus@yahoo.com>, mpm@selenic.com, andrea@suse.de,
        michaelc@cs.wisc.edu, open-iscsi@googlegroups.com,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Roland Dreier <roland@topspin.com>
In-reply-to: Your message of Mon, 28 Mar 2005 11:45:19 PST.
             <52vf7bwo4w.fsf@topspin.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


[ Can we start updating the Subject line occasionally when we have
  a specific topic, like above.  And no, I'm not top-posting, I'm
  commenting on the Subject:.  ;-)  --gerrit ]

On Mon, 28 Mar 2005 11:45:19 PST, Roland Dreier wrote:
> Let me slightly hijack this thread to throw out another topic that I
> think is worth talking about at the kernel summit: handling remote DMA
> (RDMA) network technologies.
> 
> As some of you might know, I'm one of the main authors of the
> InfiniBand support in the kernel, and I think we have things fairly
> well in hand there, although handling direct userspace access to RDMA
> capabilities may raise some issues worth talking about.
> 
> However, there is also RDMA-over-TCP hardware beginning to be used,
> based on the specs from the IETF rddp working group and the RDMA
> Consortium.  I would hope that we can abstract out the common pieces
> for InfiniBand and RDMA NIC (RNIC) support and morph
> drivers/infiniband into a more general drivers/rdma.
> 
> This is not _that_ offtopic, since RDMA NICs provide another way of
> handling OOM for iSCSI.  By having the NIC handle the network
> transport through something like iSER, you avoid a lot of the issues
> in this thread.  Having to reconnect to a target while OOM is still a
> problem, but it seems no worse in principal than the issues with a
> dump FC card that needs the host driver to handling fabric login.
> 
> I know that in the InfiniBand world, people have been able to run
> stress tests of storage over SCSI RDMA Protocol (SRP) with very heavy
> swapping going on and no deadlocks.  SRP is in effect network storage
> with the transport handled by the IB hardware.
> 
> However there are some sticky points that I would be interested in
> discussing.  For example, the IETF rddp drafts envisage what they call
> a "dual stack" model: TCP connections are set up by the usual network
> stack and run for a while in "streaming" mode until the application is
> ready to start using RDMA.  At that point there is an "MPA"
> negotiation and then the socket is handed over to the RNIC.  Clearly
> moving the state from the kernel's stack to the RNIC is not trivial.
> 
> Other developers who have more direct experience with RNIC hardware or
> perhaps just strong opinions may have other things in this area that
> they'd like to talk about.
> 
> Thanks,
>   Roland
> 
> 
> 
