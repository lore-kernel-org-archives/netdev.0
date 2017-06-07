From: Mateusz Jurczyk <mjurczyk@google.com>
Subject: Re: [PATCH v2] decnet: dn_rtmsg: Improve input length sanitization in dnrmg_receive_user_skb
Date: Wed, 7 Jun 2017 16:41:57 +0200
Message-ID: <CAPr8fOQNP+y78xJqx5BNUfY6Rmjj2R8+jrz3Ett1SgdY+a5WLw@mail.gmail.com>
References: <20170607131429.30441-1-mjurczyk@google.com> <20170607141429.5781-1-mjurczyk@google.com>
 <20170607141839.GD18283@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170607141839.GD18283@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 7, 2017 at 4:18 PM, Florian Westphal <fw@strlen.de> wrote:
> Mateusz Jurczyk <mjurczyk@google.com> wrote:
>> Verify that the length of the socket buffer is sufficient to cover the
>> nlmsghdr structure before accessing the nlh->nlmsg_len field for further
>> input sanitization. If the client only supplies 1-3 bytes of data in
>> sk_buff, then nlh->nlmsg_len remains partially uninitialized and
>> contains leftover memory from the corresponding kernel allocation.
>> Operating on such data may result in indeterminate evaluation of the
>> nlmsg_len < sizeof(*nlh) expression.
>>
>> The bug was discovered by a runtime instrumentation designed to detect
>> use of uninitialized memory in the kernel. The patch prevents this and
>> other similar tools (e.g. KMSAN) from flagging this behavior in the future.
>
> Instead of changing all the internal users wouldn't it be better
> to add this check once in netlink_unicast_kernel?
>

Perhaps. I must admit I'm not very familiar with this code
area/interface, so I preferred to fix the few specific cases instead
of submitting a general patch, which might have some unexpected side
effects, e.g. behavior different from one of the internal clients etc.

If you think one check in netlink_unicast_kernel is a better way to do
it, I'm happy to implement it like that.

Thanks,
Mateusz
