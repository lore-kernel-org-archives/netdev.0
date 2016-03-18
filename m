From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] openvswitch: call only into reachable nf-nat code
Date: Fri, 18 Mar 2016 17:41:36 -0400 (EDT)
Message-ID: <20160318.174136.2192911773820529432.davem@davemloft.net>
References: <1458308044-246105-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, tgraf@suug.ch, joestringer@nicira.com,
	pabeni@redhat.com, jarno@ovn.org, pablo@netfilter.org,
	ebiederm@xmission.com, fw@strlen.de, netdev@vger.kernel.org,
	dev@openvswitch.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458308044-246105-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 18 Mar 2016 14:33:45 +0100

> The openvswitch code has gained support for calling into the
> nf-nat-ipv4/ipv6 modules, however those can be loadable modules
> in a configuration in which openvswitch is built-in, leading
> to link errors:
> 
> net/built-in.o: In function `__ovs_ct_lookup':
> :(.text+0x2cc2c8): undefined reference to `nf_nat_icmp_reply_translation'
> :(.text+0x2cc66c): undefined reference to `nf_nat_icmpv6_reply_translation'
> 
> The dependency on (!NF_NAT || NF_NAT) prevents similar issues,
> but NF_NAT is set to 'y' if any of the symbols selecting
> it are built-in, but the link error happens when any of them
> are modular.
> 
> A second issue is that even if CONFIG_NF_NAT_IPV6 is built-in,
> CONFIG_NF_NAT_IPV4 might be completely disabled. This is unlikely
> to be useful in practice, but the driver currently only handles
> IPv6 being optional.
> 
> This patch improves the Kconfig dependency so that openvswitch
> cannot be built-in if either of the two other symbols are set
> to 'm', and it replaces the incorrect #ifdef in ovs_ct_nat_execute()
> with two "if (IS_ENABLED())" checks that should catch all corner
> cases also make the code more readable.
> 
> The same #ifdef exists ovs_ct_nat_to_attr(), where it does not
> cause a link error, but for consistency I'm changing it the same
> way.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 05752523e565 ("openvswitch: Interface with NAT.")
> Acked-by: Joe Stringer <joe@ovn.org>
> ---
> v2: leave (!NF_NAT || NF_NAT) dependency in there, we also need that

I'll let Pablo pick this up.
