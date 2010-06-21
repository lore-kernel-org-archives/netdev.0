From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6] bonding: remove unused macro "pr_fmt""
Date: Mon, 21 Jun 2010 14:22:36 -0700
Message-ID: <1277155356.1775.208.camel@Joe-Laptop.home>
References: <20100621193405.GG2656@psychotron.bos.redhat.com>
	 <20100621.133806.226761715.davem@davemloft.net>
	 <20100621204411.GL2656@psychotron.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1239 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753480Ab0FUVWi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jun 2010 17:22:38 -0400
In-Reply-To: <20100621204411.GL2656@psychotron.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-06-21 at 22:44 +0200, Jiri Pirko wrote:
> Mon, Jun 21, 2010 at 10:38:06PM CEST, davem@davemloft.net wrote:
> >From: Jiri Pirko <jpirko@redhat.com>
> >Date: Mon, 21 Jun 2010 21:34:06 +0200
> >> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> >> -#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> >Jiri, it is used by every single pr_*() logging call made
> >in this file.
> >I was hoping that this facilty and the voluminous amounty of pervasive
> >usage of this in the networking drivers nowadays would make it
> >familiar to active hackers like you :-)
> 
> Ough, right, missed that. That's just strange. I don't like this.

At some point in the future, this

#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

should be the default in kernel.h and only files that
want to change the setting should add it.

Then all the current uses (~175) in the rest of the
sources would be superfluous and could be removed.

I've plans to eventually convert the pr_<level> macros
to functions  using a vsnprintf %pV mechanism.

see: http://lkml.org/lkml/2010/3/5/33

The KBUILD_MODNAME could also be emitted by the
pr_<level> functions rather than stored in
the format string to save quite a bit of text.

Something like below would be a start:

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 8317ec4..41544c8 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -378,7 +378,7 @@ static inline char *pack_hex_byte(char *buf, u8 byte)
 extern int hex_to_bin(char ch);
 
 #ifndef pr_fmt
-#define pr_fmt(fmt) fmt
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #endif
 
 #define pr_emerg(fmt, ...) \


