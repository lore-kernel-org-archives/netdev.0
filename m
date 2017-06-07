From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2] decnet: dn_rtmsg: Improve input length sanitization
 in dnrmg_receive_user_skb
Date: Wed, 7 Jun 2017 16:18:39 +0200
Message-ID: <20170607141839.GD18283@breakpoint.cc>
References: <20170607131429.30441-1-mjurczyk@google.com>
 <20170607141429.5781-1-mjurczyk@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Mateusz Jurczyk <mjurczyk@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170607141429.5781-1-mjurczyk@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mateusz Jurczyk <mjurczyk@google.com> wrote:
> Verify that the length of the socket buffer is sufficient to cover the
> nlmsghdr structure before accessing the nlh->nlmsg_len field for further
> input sanitization. If the client only supplies 1-3 bytes of data in
> sk_buff, then nlh->nlmsg_len remains partially uninitialized and
> contains leftover memory from the corresponding kernel allocation.
> Operating on such data may result in indeterminate evaluation of the
> nlmsg_len < sizeof(*nlh) expression.
> 
> The bug was discovered by a runtime instrumentation designed to detect
> use of uninitialized memory in the kernel. The patch prevents this and
> other similar tools (e.g. KMSAN) from flagging this behavior in the future.

Instead of changing all the internal users wouldn't it be better
to add this check once in netlink_unicast_kernel?
