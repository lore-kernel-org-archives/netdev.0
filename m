From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: filter: rename 'struct sk_filter' to
 'struct bpf_prog'
Date: Mon, 28 Jul 2014 18:16:21 -0700 (PDT)
Message-ID: <20140728.181621.1196619942413270695.davem@davemloft.net>
References: <CAMEtUux8F4xZ77_HQADfoeV-9sibaEWm=XJcAaY+cQyDWb2caA@mail.gmail.com>
	<20140728214552.GA4049@salvia>
	<CAMEtUuyuxfs7Liy_HCDijUX9Q8yziY2kt0XCpJtXUyMR1P941Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, dborkman@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, willemb@google.com,
	netfilter-devel@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuyuxfs7Liy_HCDijUX9Q8yziY2kt0XCpJtXUyMR1P941Q@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Mon, 28 Jul 2014 18:12:05 -0700

> On Mon, Jul 28, 2014 at 2:45 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>>> > struct sk_filter_cb {
>>> >         int type;
>>> >         struct module *me;
>>> >         void (*charge)(struct sock *sk, struct sk_filter *fp);
>>> >         void (*uncharge)(struct sock *sk, struct sk_filter *fp);
>>> >         unsigned int (*run_filter)(struct sk_filter *fp, struct sk_buff *skb);
>>> > };
>>>
>>> Pablo,
>>>
>>> I don't think you understand the scope of BPF.
>>> 'struct module *'? to attach nft to sockets? ouch.
>>
>> The idea is that there will be one sk_filter_cb per socket filtering
>> approach. The structure module is just there in case one of the
>> approach is loadable as kernel module, it's the typical code pattern
>> in the kernel. You can git grep for similar code.
> 
> socket filtering is available to unprivileged users.
> So you're proposing to let them increment refcnt of modules?!
> That's not secure.

It's impossible to avoid, and really is nothing new.

Users can open sockets, and that holds a reference to the module
implementing that protocol.  Is that not secure too?

This discussion is degenerating into nonsense, please stop ignoring
Pablo's core points.

Thanks.
