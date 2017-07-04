From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] vmalloc: respect the GFP_NOIO and GFP_NOFS flags
Date: Tue, 4 Jul 2017 10:10:07 +0200
Message-ID: <20170704081007.GA14722@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1706292221250.21823@file01.intranet.prod.int.rdu2.redhat.com>
 <20170630081245.GA22917@dhcp22.suse.cz>
 <alpine.LRH.2.02.1706301410160.8272@file01.intranet.prod.int.rdu2.redhat.com>
 <20170630204059.GA17255@dhcp22.suse.cz>
 <alpine.LRH.2.02.1706302033230.13879@file01.intranet.prod.int.rdu2.redhat.com>
 <20170703062905.GB3217@dhcp22.suse.cz>
 <alpine.LRH.2.02.1707031703590.20792@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Vlastimil Babka <vbabka@suse.cz>,
        Andreas Dilger <adilger@dilger.ca>,
        John Hubbard <jhubbard@nvidia.com>,
        David Miller <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        netdev@vger.kernel.org
To: Mikulas Patocka <mpatocka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1707031703590.20792@file01.intranet.prod.int.rdu2.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon 03-07-17 18:57:14, Mikulas Patocka wrote:
> 
> 
> On Mon, 3 Jul 2017, Michal Hocko wrote:
> 
> > We can add a warning (or move it from kvmalloc) and hope that the
> > respective maintainers will fix those places properly. The reason I
> > didn't add the warning to vmalloc and kept it in kvmalloc was to catch
> > only new users rather than suddenly splat on existing ones. Note that
> > there are users with panic_on_warn enabled.
> > 
> > Considering how many NOFS users we have in tree I would rather work with
> > maintainers to fix them.
> 
> So - do you want this patch?

no, see below
 
> I still believe that the previous patch that pushes 
> memalloc_noio/nofs_save into __vmalloc is better than this.

It is, but both of them are actually wrong. Why? Because that would be
just a mindless application of the scope where the scope doesn't match
the actual reclaim recursion restricted scope. Really, the right way to
go is to simply talk to the respective maintainers. Find out whether
NOFS context is really needed and if so find the scope (e.g. a lock
which would be needed in the reclaim context) and document it. This is
not a trivial work to do but a) we do not seem to have any bug reports
complaining about these call sites so there is no need to hurry and b)
this will result in a cleaner and easier to maintain code.
-- 
Michal Hocko
SUSE Labs
