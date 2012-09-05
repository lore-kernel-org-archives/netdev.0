From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NULL pointer dereference in xt_register_target()
Date: Wed, 05 Sep 2012 18:12:49 +0200
Message-ID: <1346861569.13121.149.camel@edumazet-glaptop>
References: <CAM_iQpVUZ50RYLUgEHbcm7ua996hgE7Gj-P-bWNJutuvm1nUoQ@mail.gmail.com>
	 <1346860506.13121.148.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:62589 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001Ab2IEQM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 12:12:57 -0400
In-Reply-To: <1346860506.13121.148.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-05 at 17:55 +0200, Eric Dumazet wrote:
> On Wed, 2012-09-05 at 23:43 +0800, Cong Wang wrote:
> > Hi, folks,
> > 
> > The latest net-next tree can't boot due to a NULL ptr def
> > bug in the kernel, the full backtrack is:
> > 
> > http://img1.douban.com/view/photo/photo/public/p1697139550.jpg
> > 
> > the kernel .config file is:
> > 
> > http://pastebin.com/9YTnkqKN
> > 
> > I don't have time to look into the issue. If you need other info,
> > please let me know.
> 
> It seems xt_nat_init() is called before xt_init(), so xt array is not
> yet setup.
> 
> 

Seems the following patch should help, I have to try it ;)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 8d987c3..afcea11 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1390,6 +1390,6 @@ static void __exit xt_fini(void)
 	kfree(xt);
 }
 
-module_init(xt_init);
+core_initcall(xt_init);
 module_exit(xt_fini);
 
