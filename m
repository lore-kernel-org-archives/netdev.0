From: Maxim Levitsky <maximlevitsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: MDNS is broken in latest -git
Date: Fri, 28 May 2010 18:02:28 +0300
Message-ID: <1275058948.2754.7.camel@maxim-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On latest git, it became impossible to use hostname.local alias to
access my network hosts.

In fact when I look at 'avahi-discover' I see nothing but local
services.

I did a bisect, but unfortunely ended with merge commit, although
bisection seem to be normal (and I didn't do any shortcuts).

I own a iwl3945 wireless card.


The bisection log:

git bisect start
# good: [537b60d17894b7c19a6060feae40299d7109d6e7] Merge branch 'x86-uv-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip
git bisect good 537b60d17894b7c19a6060feae40299d7109d6e7
# bad: [d515e86e639890b33a09390d062b0831664f04a2] Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jack/linux-udf-2.6
git bisect bad d515e86e639890b33a09390d062b0831664f04a2
# good: [a26272e5200765691e67d6780e52b32498fdb659] Merge branch 'docs-next' of git://git.lwn.net/linux-2.6
git bisect good a26272e5200765691e67d6780e52b32498fdb659
# good: [10fc51b9953112ade61e33ff2f6f005f005a2361] skge: use the DMA state API instead of the pci equivalents
git bisect good 10fc51b9953112ade61e33ff2f6f005f005a2361
# bad: [c316ba3b518bc35ce5aef5421135220389f4eb98] Merge branch 'linux-next' of git://git.infradead.org/ubi-2.6
git bisect bad c316ba3b518bc35ce5aef5421135220389f4eb98
# bad: [7a9b149212f3716c598afe973b6261fd58453b7a] Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6
git bisect bad 7a9b149212f3716c598afe973b6261fd58453b7a
# good: [726ef428af41b1fbdf569772ab73de0844c4e0f2] USB: belkin_sa: minor clean-ups
git bisect good 726ef428af41b1fbdf569772ab73de0844c4e0f2
# good: [6fe70aae0d128339febfabc073ba4c4a03de4f45] Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6 into for-davem
git bisect good 6fe70aae0d128339febfabc073ba4c4a03de4f45
# bad: [57b610805ce92dbd79fc97509f80fa5391b99623] net: Add netlink support for virtual port management (was iovnl)
git bisect bad 57b610805ce92dbd79fc97509f80fa5391b99623
# good: [78ad38923094a479453f5b02b37a012377a36f34] qlcnic: fix internal loopback test
git bisect good 78ad38923094a479453f5b02b37a012377a36f34
# good: [e1bc7eedbafe0415cdfd82e17e6f65bb3369239d] atm: select FW_LOADER in Kconfig for solos-pci
git bisect good e1bc7eedbafe0415cdfd82e17e6f65bb3369239d
# bad: [eedf042a63ffef050ebc015de19b52dc065e830b] ipv6: fix the bug of address check
git bisect bad eedf042a63ffef050ebc015de19b52dc065e830b
# good: [99bf236612801351834b441314379bc5304d62ce] drivers/net/usb: Use kmemdup
git bisect good 99bf236612801351834b441314379bc5304d62ce
# good: [380fefb2ddabd4cd5f14dbe090481f0544e65078] dm9000: fix "BUG: spinlock recursion"
git bisect good 380fefb2ddabd4cd5f14dbe090481f0544e65078
# bad: [820ae8a80eb59962aefbbd4908dfe144ec0f9edb] Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6
git bisect bad 820ae8a80eb59962aefbbd4908dfe144ec0f9edb


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
