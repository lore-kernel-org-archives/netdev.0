From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: Re: [PATCH 04/10] mm: replace get_user_pages_locked() write/force
 parameters with gup_flags
Date: Tue, 18 Oct 2016 14:56:09 +0100
Message-ID: <20161018135609.GA30025@lucifer>
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161013002020.3062-5-lstoakes@gmail.com>
 <20161018125425.GD29967@quack2.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>,
        Hugh Dickins <hughd@google.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Rik van Riel <riel@redhat.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        adi-buildroot-devel@lists.sourceforge.net,
        ceph-devel@vger.kernel.org, dri-devel@lists.freedesktop.org,
        intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org,
        linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-cris-kernel@axis.com, linux-fbdev@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
        linux-mips@linux-mips.org, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
To: Jan Kara <jack@suse.cz>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161018125425.GD29967@quack2.suse.cz>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 18, 2016 at 02:54:25PM +0200, Jan Kara wrote:
> > @@ -1282,7 +1282,7 @@ long get_user_pages(unsigned long start, unsigned long nr_pages,
> >  			    int write, int force, struct page **pages,
> >  			    struct vm_area_struct **vmas);
> >  long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
> > -		    int write, int force, struct page **pages, int *locked);
> > +		    unsigned int gup_flags, struct page **pages, int *locked);
>
> Hum, the prototype is inconsistent with e.g. __get_user_pages_unlocked()
> where gup_flags come after **pages argument. Actually it makes more sense
> to have it before **pages so that input arguments come first and output
> arguments second but I don't care that much. But it definitely should be
> consistent...

It was difficult to decide quite how to arrange parameters as there was
inconsitency with regards to parameter ordering already - for example
__get_user_pages() places its flags argument before pages whereas, as you note,
__get_user_pages_unlocked() puts them afterwards.

I ended up compromising by trying to match the existing ordering of the function
as much as I could by replacing write, force pairs with gup_flags in the same
location (with the exception of get_user_pages_unlocked() which I felt should
match __get_user_pages_unlocked() in signature) or if there was already a
gup_flags parameter as in the case of __get_user_pages_unlocked() I simply
removed the write, force pair and left the flags as the last parameter.

I am happy to rearrange parameters as needed, however I am not sure if it'd be
worthwhile for me to do so (I am keen to try to avoid adding too much noise here
:)

If we were to rearrange parameters for consistency I'd suggest adjusting
__get_user_pages_unlocked() to put gup_flags before pages and do the same with
get_user_pages_unlocked(), let me know what you think.
