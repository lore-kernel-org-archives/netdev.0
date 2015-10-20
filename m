From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next 0/4] netfilter: rework netfilter ipv6 defrag
Date: Tue, 20 Oct 2015 10:17:16 +0200
Message-ID: <20151020081716.GH4386@breakpoint.cc>
References: <1445112865-31523-1-git-send-email-fw@strlen.de>
 <CANr6G5zvmj_tL5Pt6-70GQ4dTJXLewX9A4uMGC_0OFzXYQVdew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andy Zhou <azhou@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CANr6G5zvmj_tL5Pt6-70GQ4dTJXLewX9A4uMGC_0OFzXYQVdew@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Stringer <joestringer@nicira.com> wrote:
> On 17 October 2015 at 13:14, Florian Westphal <fw@strlen.de> wrote:
> > [ CC netdev since patch #2 isn't nf-specific.  Dave, if you want
> >   I can resubmit that one after the next nf-pull request; let me know if
> >   you would prefer that ].
> >
> > Openvswitch seems broken wrt. to defragmentation, it doesn't call
> > nf_ct_frag6_consume_orig to free the original fragments.
> 
> This will need to be fixed for 'net' as well, do you have a path in
> mind for that?

Good point.  No, I don't.  Any suggestions?
I can try to just re-target -nf tree (sans patch #2).  Pablo?

ipv4 side seems broken as well (ip_defrag frees skb on errors other than
-EINPROGRESS, so it looks like we will double-free in
do_execute_actions)

> Patch 3 when taken independently from patch 4 hides user-visible error
> codes on the OVS side. The OVS conntrack action hides -EINPROGRESS
> from userspace, treating it as a successful execution. All other
> errors are returned up. With that patch, all errors will be hidden. I
> see that it's fixed in Patch 4, so maybe it's not a biggie but those
> two patches should be tightly coupled.

You're right, we can't signal "skb unchanged".  I guess one could
just test wheter skb is a fragment and -EINVAL if it is, not sure
if its worth doing given that such test would be removed again
by the very next patch?
