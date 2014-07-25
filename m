From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] net: filter: rename 'struct sk_filter' to
 'struct bpf_prog'
Date: Fri, 25 Jul 2014 10:27:14 -0700
Message-ID: <CAMEtUuxjvR-3cBq=x0d_7qYtF+TP3NdjPxsYP6pn4iE7gzLhpg@mail.gmail.com>
References: <1406275499-7822-1-git-send-email-ast@plumgrid.com>
	<53D23EAF.4000001@redhat.com>
	<20140725115414.GA4770@salvia>
	<CA+FuTScUJ-oJKAZ-MO_t9Rmah3U6G4sjHXLJSMrXVK5+fN0zyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CA+FuTScUJ-oJKAZ-MO_t9Rmah3U6G4sjHXLJSMrXVK5+fN0zyg@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 25, 2014 at 6:53 AM, Willem de Bruijn <willemb@google.com> wrote:
>>> >alternative fix for xt_bpf.h could be to replace:
>>> >         /* only used in the kernel */
>>> >     struct sk_filter *filter __attribute__((aligned(8)));
>>> >with
>>> >         /* only used in the kernel */
>>> >     void *filter __attribute__((aligned(8)));
>>> >
>>> >but this 'void *' approach may further break broken userspace,
>>> >whereas the fix implemented here is more seamless.
>>>
>>> Yep, that's not good, 'struct sk_filter' should never have been in a uapi
>>> file actually.
>
> This follows a convention in include/uapi/linux/netfilter/*.h that
> likely predates the introduction of uapi. A search for "Used
> internally by the kernel" shows many more examples. I should not have
> included filter.h, however. The common behavior when using pointers
> to kernel-internal structures is to have a forward declaration. I suggest
> making that change, instead of changing to void *. This avoids having
> to add casts where xt_bpf_info is used in net/netfilter/xt_bpf.c:

that will not avoid typecast.
Either 'void *' approach or extra 'struct sk_filter;' approach, both need
type casts to 'struct bpf_prog' in xt_bpf.c
(because of SK_RUN_FILTER macro)
Therefore I prefer extra 'struct sk_filter;' approach.

> -#include <linux/filter.h>
>  #include <linux/types.h>
>
>  #define XT_BPF_MAX_NUM_INSTR   64
>
> +struct sk_filter;
> +
>  struct xt_bpf_info {
>
> I can send this as a separate patch to net-next, if that helps.
