From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix memory leak in
 net/ipv4/tcp_probe.c::tcpprobe_read()
Date: Thu, 10 Aug 2006 16:36:12 -0700 (PDT)
Message-ID: <20060810.163612.71164812.davem@davemloft.net>
References: <9a8748490608041630t5e667bf5k3a50dcf148187e6c@mail.gmail.com>
	<20060804.165931.48505912.davem@davemloft.net>
	<9a8748490608101518s38c6e6a3r9d8599ca3c106ef3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, shemminger@osdl.org, kuznet@ms2.inr.ac.ru,
	yoshfuji@linux-ipv6.org, pekkas@netcore.fi, kaber@coreworks.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:12770
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932286AbWHJXgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 19:36:17 -0400
To: jesper.juhl@gmail.com
In-Reply-To: <9a8748490608101518s38c6e6a3r9d8599ca3c106ef3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jesper Juhl" <jesper.juhl@gmail.com>
Date: Fri, 11 Aug 2006 00:18:44 +0200

> Hmm, perhaps I'm going blind, but I don't see it.

I definitely screwed that changeset up somehow.  Thanks for catching
this.

Somehow James's fix got clobbered into just my subsequent warning fix,
like this:

commit 118075b3cdc90e0815362365f3fc64d672ace0d6
Author: James Morris <jmorris@namei.org>
Date:   Sun Jul 30 20:21:45 2006 -0700

    [TCP]: fix memory leak in net/ipv4/tcp_probe.c::tcpprobe_read()
    
    Based upon a patch by Jesper Juhl.
    
    Signed-off-by: James Morris <jmorris@namei.org>
    Acked-by: Stephen Hemminger <shemminger@osdl.org>
    Acked-by: Jesper Juhl <jesper.juhl@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index d7d517a..b343532 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -114,7 +114,7 @@ static int tcpprobe_open(struct inode * 
 static ssize_t tcpprobe_read(struct file *file, char __user *buf,
 			     size_t len, loff_t *ppos)
 {
-	int error = 0, cnt;
+	int error = 0, cnt = 0;
 	unsigned char *tbuf;
 
 	if (!buf || len < 0)

Anyways, I'll fix this up, thanks again.
