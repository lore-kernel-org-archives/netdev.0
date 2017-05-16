From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Tue, 16 May 2017 15:28:19 -0400
Message-ID: <1494962899.3259.141.camel@redhat.com>
References: <1494955244.3259.130.camel@redhat.com>
         <20170516.133644.850927380166261577.davem@davemloft.net>
         <1494957802.3259.131.camel@redhat.com>
         <20170516.145249.871010194359061722.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
        hch-jcswGhMUV9g@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170516.145249.871010194359061722.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-05-16 at 14:52 -0400, David Miller wrote:
> From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Date: Tue, 16 May 2017 14:03:22 -0400
> 
> > On Tue, 2017-05-16 at 13:36 -0400, David Miller wrote:
> >> From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> >> Date: Tue, 16 May 2017 13:20:44 -0400
> >> 
> >> > Anyway, we're just talking out what happened, when what we
> really
> >> need
> >> > to focus on is moving forward.  Again, your thoughts on marking
> SMC
> >> > EXPERIMENTAL until it's fixed up and unfreezing the API in case
> we
> >> need
> >> > to adjust it to work on different link layers?
> >> 
> >> Something like:
> >> 
> >>         http://patchwork.ozlabs.org/patch/762803/
> >> 
> >> with the addition of the EXPERIMENTAL dependency?
> >> 
> >> Sure.
> > 
> > Perfect.  I assume you'll submit it since it's in your patchworks?
> 
> Ok I applied the patch referenced above, but we don't actually have
> an EXPERIMENTAL symbol.  The closest thing we have is BROKEN and
> even in this situation that's a bit harsh.

I hadn't realized EXPERIMENTAL was gone.  Which is too bad, because
that's entirely appropriate in this case, and would have had the
desired side effect of keeping it out of any non-cutting edge distros
and warning people of possible API changes.  With EXPERIMENTAL gone,
the closest thing we have is drivers/staging, since that tends to imply
some of the same consequences.  I know you think BROKEN is overly
harsh, but I'm not sure we should just do nothing.  How about we take a
few days to let some of the RDMA people closely review the 143 page
(egads!) rfc (http://www.rfc-editor.org/info/rfc7609) to see if we
think it can be fixed to use multiple link layers with the existing API
in place or if it will require something other than AF_SMC.  If we need
to break API, then I think we should either fix it ASAP and send that
fix to the 4.11 stable series (which probably violates the normative
stable patch size/scope) or if the fix will take longer than this
kernel cycle, then move it to staging both here and in 4.11 stable, and
fix it there and then move it back.  Something like that would prevent
the kind of API flappage we ought not do....

-- 
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
