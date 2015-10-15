From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH] Fix sleeping memory allocation in atomic context
Date: Thu, 15 Oct 2015 12:18:39 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1510151216590.8348@blackhole.kfki.hu>
References: <1444899472-8191-1-git-send-email-kernel@kyup.com> <561F7C50.6080401@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Nikolay Borisov <kernel@kyup.com>, pablo@netfilter.org,
	davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, operations@siteground.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <561F7C50.6080401@cumulusnetworks.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Oct 2015, Nikolay Aleksandrov wrote:

> On 10/15/2015 10:57 AM, Nikolay Borisov wrote:
> > Ipset 6.26 produces the following splat:
> > 
> [snip]
> > 
> > The call chain leading to this as follow:
> > call_add -> list_set_uadt -> list_set_uadd -> kzalloc(, GFP_KERNEL).
> > And since GFP_KERNEL allows initiating direct reclaim thus
> > potentially sleeping in the allocation path, this leads to the
> > aforementioned splat.
> > 
> > To fix it change that particular allocation type to GFP_ATOMIC, to
> > correctly reflect that it is happening in an atomic context.
> > 
> > Signed-off-by: Nikolay Borisov <kernel@kyup.com>
> > ---
> > 
> > Even though this patch has been generated against the stand-alone
> > ipset sources I just checked the 4.3-rc4 sources and the problem
> > exists there as well.
> > 
> >  kernel/net/netfilter/ipset/ip_set_list_set.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/kernel/net/netfilter/ipset/ip_set_list_set.c b/kernel/net/netfilter/ipset/ip_set_list_set.c
> > index b11ba96..0f9195f 100644
> 
> Hi,
> You should fix your subject line to include the subsystem [1], something like
> netfilter: ipset: fix...
> The path to the file being patched is incorrect, patches should be generated in
> the root kernel source dir [2].
> Also it'd be nice to add a Fixes tag [3] to show which commit introduced the bug,
> in this case it looks like it's:
> Fixes: 00590fdd5be0 ("netfilter: ipset: Introduce RCU locking in list type")

The patch was created against the ipset package and not the kernel tree 
itself, so yes, a respin is needed.

Best regards,
Jozsef
 
> [1] Documentation/SubmittingPatches chapter 14
> [2] Documentation/SubmittingPatches chapter 1
> [3] Documentation/SubmittingPatches chapters 2 and 13
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
