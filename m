From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [netlink] WARNING: at mm/vmalloc.c:1487 __vunmap()
Date: Sat, 15 Jun 2013 13:57:02 +0800
Message-ID: <CAM_iQpWu2U5UmHhvmnqNenbWyz7vng8W+b0AssE31FSgSd9DLg@mail.gmail.com>
References: <20130614220119.GA12954@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f44.google.com ([209.85.212.44]:60231 "EHLO
	mail-vb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753172Ab3FOF5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jun 2013 01:57:04 -0400
In-Reply-To: <20130614220119.GA12954@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 15, 2013 at 6:01 AM, Fengguang Wu <fengguang.wu@intel.com> wrote:
> Greetings,
>
> I got the below dmesg and the first bad commit is
>
> commit c05cdb1b864f548c0c3d8ae3b51264e6739a69b1
> Author: Pablo Neira Ayuso <pablo@netfilter.org>
> Date:   Mon Jun 3 09:46:28 2013 +0000
>
>     netlink: allow large data transfers from user-space

Hi, Fengguang,

Could you try the following quick fix?

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 8978755..d8c6c03 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -750,7 +750,7 @@ static void netlink_skb_destructor(struct sk_buff *skb)
                skb->head = NULL;
        }
 #endif
-       if (is_vmalloc_addr(skb->head)) {
+       else if (is_vmalloc_addr(skb->head)) {
                vfree(skb->head);
                skb->head = NULL;
        }
