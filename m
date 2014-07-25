From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] net: filter: rename 'struct sk_filter' to
 'struct bpf_prog'
Date: Fri, 25 Jul 2014 11:43:05 -0700
Message-ID: <CAMEtUux8c2OdLTFOYY9af1O6LK6zaYhZ1rm3RZxiMOLpTE6P6A@mail.gmail.com>
References: <1406275499-7822-1-git-send-email-ast@plumgrid.com>
	<53D23EAF.4000001@redhat.com>
	<20140725115414.GA4770@salvia>
	<CA+FuTScUJ-oJKAZ-MO_t9Rmah3U6G4sjHXLJSMrXVK5+fN0zyg@mail.gmail.com>
	<CAMEtUuxjvR-3cBq=x0d_7qYtF+TP3NdjPxsYP6pn4iE7gzLhpg@mail.gmail.com>
	<CA+FuTSeKpu7u=KyGeiWpEDLWgxkPDRUtSc9fixR93jxsTCkc0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:59081 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759716AbaGYSnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 14:43:07 -0400
Received: by mail-wi0-f169.google.com with SMTP id n3so1529250wiv.4
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2014 11:43:05 -0700 (PDT)
In-Reply-To: <CA+FuTSeKpu7u=KyGeiWpEDLWgxkPDRUtSc9fixR93jxsTCkc0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 25, 2014 at 11:32 AM, Willem de Bruijn <willemb@google.com> wrote:
>>> This follows a convention in include/uapi/linux/netfilter/*.h that
>>> likely predates the introduction of uapi. A search for "Used
>>> internally by the kernel" shows many more examples. I should not have
>>> included filter.h, however. The common behavior when using pointers
>>> to kernel-internal structures is to have a forward declaration. I suggest
>>> making that change, instead of changing to void *. This avoids having
>>> to add casts where xt_bpf_info is used in net/netfilter/xt_bpf.c:
>>
>> that will not avoid typecast.
>> Either 'void *' approach or extra 'struct sk_filter;' approach, both need
>> type casts to 'struct bpf_prog' in xt_bpf.c
>> (because of SK_RUN_FILTER macro)
>> Therefore I prefer extra 'struct sk_filter;' approach.
>
> I hadn't noticed that your patch makes the same change that I
> proposed. Nothing in userspace should touch that pointer, so it is
> fine to change its type to struct bpf_prog* at the same time. No need
> for typecasts.

really? I don't think it's a good idea to expose kernel struct type
to user space. How is it even going to compile?
#include <linux/filter.h> brings different files in kernel and in user space.
struct bpf_prog is undefined in user space and compiler will complain.
Adding 'struct bpf_prog;' will be ugly.
imo the lesser evil is adding 'struct sk_filter;' and doing type casts
in kernel.
