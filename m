From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] net: filter: rename 'struct sk_filter' to
 'struct bpf_prog'
Date: Sat, 26 Jul 2014 00:20:55 +0200
Message-ID: <20140725222055.GB3729@salvia>
References: <1406275499-7822-1-git-send-email-ast@plumgrid.com>
 <53D23EAF.4000001@redhat.com>
 <20140725115414.GA4770@salvia>
 <CA+FuTScUJ-oJKAZ-MO_t9Rmah3U6G4sjHXLJSMrXVK5+fN0zyg@mail.gmail.com>
 <CAMEtUuxjvR-3cBq=x0d_7qYtF+TP3NdjPxsYP6pn4iE7gzLhpg@mail.gmail.com>
 <CA+FuTSeKpu7u=KyGeiWpEDLWgxkPDRUtSc9fixR93jxsTCkc0g@mail.gmail.com>
 <CAMEtUux8c2OdLTFOYY9af1O6LK6zaYhZ1rm3RZxiMOLpTE6P6A@mail.gmail.com>
 <CA+FuTSeK3BCqa+4nXe8WwvqNH86pK36=uwvfnkiA-EsN_gnEkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Willem de Bruijn <willemb@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+FuTSeK3BCqa+4nXe8WwvqNH86pK36=uwvfnkiA-EsN_gnEkA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 25, 2014 at 02:50:32PM -0400, Willem de Bruijn wrote:
> On Fri, Jul 25, 2014 at 2:43 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> > On Fri, Jul 25, 2014 at 11:32 AM, Willem de Bruijn <willemb@google.com> wrote:
> >>>> This follows a convention in include/uapi/linux/netfilter/*.h that
> >>>> likely predates the introduction of uapi. A search for "Used
> >>>> internally by the kernel" shows many more examples. I should not have
> >>>> included filter.h, however. The common behavior when using pointers
> >>>> to kernel-internal structures is to have a forward declaration. I suggest
> >>>> making that change, instead of changing to void *. This avoids having
> >>>> to add casts where xt_bpf_info is used in net/netfilter/xt_bpf.c:
> >>>
> >>> that will not avoid typecast.
> >>> Either 'void *' approach or extra 'struct sk_filter;' approach, both need
> >>> type casts to 'struct bpf_prog' in xt_bpf.c
> >>> (because of SK_RUN_FILTER macro)
> >>> Therefore I prefer extra 'struct sk_filter;' approach.
> >>
> >> I hadn't noticed that your patch makes the same change that I
> >> proposed. Nothing in userspace should touch that pointer, so it is
> >> fine to change its type to struct bpf_prog* at the same time. No need
> >> for typecasts.
> >
> > really? I don't think it's a good idea to expose kernel struct type
> > to user space. How is it even going to compile?
> 
> a forward declaration.
> 
> > #include <linux/filter.h> brings different files in kernel and in user space.
> > struct bpf_prog is undefined in user space and compiler will complain.
> > Adding 'struct bpf_prog;' will be ugly.
> > imo the lesser evil is adding 'struct sk_filter;' and doing type casts
> > in kernel.
> 
> but the exact same argument applies to sk_filter. If that struct is
> renamed everywhere else, then the result will only be more confusing.
> A forward declaration is the standard workaround to all such cases in
> include/uapi/linux/netfilter. See for instance xt_connlimit.h. This is
> sufficient to allow userspace build to succeed, without exposing any
> kernel structure detail. If you don't even want to leak the name, then
> let's make it void *. Keeping a declaration for sk_filter, while
> sk_filter is renamed everywhere else is the least good option, in my
> opinion.

Please, send me a patch to remove that include <net/filter.h> from the
uapi header and define struct sk_filter; so we save the typecast in
xt_bpf.c

The struct sk_filter; doesn't expose anything relevant since, even
assuming userspace knows the layout, it can *not* do anything useful
with that.

Thanks.
