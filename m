From: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Subject: Re: [PATCH] SIW: Object management
Date: Sat, 9 Oct 2010 16:10:46 +0200
Message-ID: <OF1E676C64.A340B840-ONC12577B7.0049A69D-C12577B7.004DE449@ch.ibm.com>
References: <1286261665-5175-1-git-send-email-bmt@zurich.ibm.com> <4CAB35A8.6080906@opengridcomputing.com> <OF706D1D5F.5849676F-ONC12577B3.004FB763-C12577B3.00521572@ch.ibm.com> <4CAB3E0D.8050609@opengridcomputing.com> <OFFCB10B70.3E1CC39D-ONC12577B3.0053113C-C12577B3.0054C076@ch.ibm.com> <4CAB464D.5030702@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
To: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4CAB464D.5030702-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

<snip>

> > 
> >> the post_send/recv and other functions in your driver are called
> >> directly (almost) by kernel users like NFSRDMA.  These users may be
> >> calling in an interrupt context and thus you cannot block/sleep.
> >>
> >> 
> > OK, very convincing. not a big change since siw_wqe_get/_put()
> > already maintain a list of pre-allocated wqe's (currently for
> > the read.responses).
> > but, would it be ok if the code distinguishes between user
> > land and in-kernel consumers? i would be very happy if we could
> > keep the pre-allocations per user land connection to its very
> > minimum...
> >
> > 
> 
> I think that's ok, but its bending the core locking rules a little I 
> guess.  But the intent is that kernel users can definitely 
> send/recv/poll in interrupt context, so possibly blocking for user mode 
> QPs in on-kernel-bypass operations is probably ok...
> 
i think its best if the code can be optimized this way. i will provide
a patch following down that path soon after i am back from vacation
(next week i am off).
while respecting the specific kernel user requirements, i really want
to keep memory allocations small for user land applications. 

thanks,
bernard.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
