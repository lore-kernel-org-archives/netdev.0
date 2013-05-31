From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH 1/5] netfilter: add nf_ipv6_ops hook to fix xt_addrtype
 with IPv6
Date: Fri, 31 May 2013 09:24:35 +0900
Message-ID: <CAKD1Yr3aauNq0NAi1-RDxcD_D5GDwzO87WxUARhyh=iQe91A5Q@mail.gmail.com>
References: <1369843394-24251-1-git-send-email-pablo@netfilter.org> <1369843394-24251-2-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1369843394-24251-2-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 30, 2013 at 1:03 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> 2) add new "nf_ipv6_ops" struct to register pointers to ipv6 functions.
>
> While the former might seem preferable, Pablo pointed out that there
> are more xt modules with link-time dependeny issues regarding ipv6,
> so lets go for 2).

I had to do this recently for the ping socket as well:

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=6d0bfe22611602f36617bc7aa2ffa1bbb2f54c67

+/* Compatibility glue so we can support IPv6 when it's compiled as a module */
+struct pingv6_ops {
[...]
+ int (*ipv6_chk_addr)(struct net *net, const struct in6_addr *addr,
+     struct net_device *dev, int strict);
+};

Is it a better idea to share these structures and have just one
structure containing all IPv6 dummy functions? If it was in an include
file, it would be easily accessible to most of the tree even when
CONFIG_IPV6={n,m}, and we could have the ipv6 module init (and exit)
code just set all the function pointers. That way, we wouldn't have to
reinvent this particular wheel in multiple places of the code.

David?

[Personally, I'd just rather see CONFIG_IPV6=m go away, since it adds
a lot of complexity like this and doesn't bring much benefit that I
can see, but I doubt there will be agreement on that :-)]
