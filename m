From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 37/50] netfilter: nf_tables: atomic dump and reset for
 stateful objects
Date: Fri, 9 Dec 2016 11:24:32 +0100
Message-ID: <20161209102432.GA986@salvia>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
 <1481147576-5690-38-git-send-email-pablo@netfilter.org>
 <CAP=VYLp-ZBFjR1W9=V_vyPYAi1=Yub3ugq6D8hkoLigcPaaxFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="gKMricLos+KVdGMg"
Cc: netfilter-devel@vger.kernel.org,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46266 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933105AbcLIKYr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Dec 2016 05:24:47 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id D40D41395C2
        for <netdev@vger.kernel.org>; Fri,  9 Dec 2016 11:24:44 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id C170C7E082
        for <netdev@vger.kernel.org>; Fri,  9 Dec 2016 11:24:44 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 571127E07F
        for <netdev@vger.kernel.org>; Fri,  9 Dec 2016 11:24:41 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <CAP=VYLp-ZBFjR1W9=V_vyPYAi1=Yub3ugq6D8hkoLigcPaaxFg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Paul,

On Thu, Dec 08, 2016 at 07:40:14PM -0500, Paul Gortmaker wrote:
> On Wed, Dec 7, 2016 at 4:52 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > This patch adds a new NFT_MSG_GETOBJ_RESET command perform an atomic
> > dump-and-reset of the stateful object. This also comes with add support
> > for atomic dump and reset for counter and quota objects.
> 
> This triggered a new build failure in linux-next on parisc-32, which a
> hands-off bisect
> run lists as resulting from this:
> 
> ERROR: "__cmpxchg_u64" [net/netfilter/nft_counter.ko] undefined!
> make[2]: *** [__modpost] Error 1
> make[1]: *** [modules] Error 2
> make: *** [sub-make] Error 2
> 43da04a593d8b2626f1cf4b56efe9402f6b53652 is the first bad commit
> commit 43da04a593d8b2626f1cf4b56efe9402f6b53652
> Author: Pablo Neira Ayuso <pablo@netfilter.org>
> Date:   Mon Nov 28 00:05:44 2016 +0100
> 
>     netfilter: nf_tables: atomic dump and reset for stateful objects
> 
>     This patch adds a new NFT_MSG_GETOBJ_RESET command perform an atomic
>     dump-and-reset of the stateful object. This also comes with add support
>     for atomic dump and reset for counter and quota objects.
> 
>     Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> :040000 040000 6cd4554f69247e5c837db52342f26888beda1623
> 5908aca93c89e7922336546c3753bfcf2aceefba M      include
> :040000 040000 f25d5831eb30972436bd198c5bb237a0cb0b4856
> 4ee5751c8de02bb5a8dcaadb2a2df7986d90f8e9 M      net
> bisect run success
> 
> Guessing this is more an issue with parisc than it is with netfilter, but I
> figured I'd mention it anyway.

I'm planning to submit this patch to parisc, I'm attaching it to this
email.

--gKMricLos+KVdGMg
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-parisc-export-symbol-__cmpxchg_u64.patch"

>From c9d320ac0be2a32a7b2bfad398be549865088ecf Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 8 Dec 2016 22:55:33 +0100
Subject: [PATCH] parisc: export symbol __cmpxchg_u64()

kbuild test robot reports:

>> ERROR: "__cmpxchg_u64" [net/netfilter/nft_counter.ko] undefined!

Commit 43da04a593d8 ("netfilter: nf_tables: atomic dump and reset for
stateful objects") introduces the first client of cmpxchg64() from
modules.

Patch 54b668009076 ("parisc: Add native high-resolution sched_clock()
implementation") removed __cmpxchg_u64() dependency on CONFIG_64BIT.
So, let's fix this problem by exporting this symbol unconditionally.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 arch/parisc/kernel/parisc_ksyms.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/parisc/kernel/parisc_ksyms.c b/arch/parisc/kernel/parisc_ksyms.c
index 3cad8aadc69e..cfa704548cf3 100644
--- a/arch/parisc/kernel/parisc_ksyms.c
+++ b/arch/parisc/kernel/parisc_ksyms.c
@@ -40,8 +40,8 @@ EXPORT_SYMBOL(__atomic_hash);
 #endif
 #ifdef CONFIG_64BIT
 EXPORT_SYMBOL(__xchg64);
-EXPORT_SYMBOL(__cmpxchg_u64);
 #endif
+EXPORT_SYMBOL(__cmpxchg_u64);
 
 #include <asm/uaccess.h>
 EXPORT_SYMBOL(lclear_user);
-- 
2.1.4


--gKMricLos+KVdGMg--
