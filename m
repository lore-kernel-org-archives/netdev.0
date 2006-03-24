From: Patrick McHardy <kaber@trash.net>
Subject: Re: [2.6 patch] ip_conntrack_helper_h323.c: EXPORT_SYMBOL'ed
 functions shouldn't be static
Date: Fri, 24 Mar 2006 02:27:44 +0100
Message-ID: <44234B10.5040802@trash.net>
References: <20060324000801.GM22727@stusta.de>
	<20060323.161314.59991770.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020904020401040302050807"
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	zhaojignmin@hotmail.com, linux-kernel@vger.kernel.org, bunk@stusta.de
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060323.161314.59991770.davem@davemloft.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020904020401040302050807
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

David S. Miller wrote:
> From: Adrian Bunk <bunk@stusta.de>
> Date: Fri, 24 Mar 2006 01:08:01 +0100
> 
> 
>>EXPORT_SYMBOL'ed functions shouldn't be static.
>>
>>Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> 
> Fixed in Linus's tree as of yesterday.
> 
> I actually have a patch from Patrick McHardy that will make
> this kind of error a build time failure instead of silently
> working in the modular case.  I just need to test it out
> a bit before pushing.

I guess I should send it to lkml anyway. It boots fine, I couldn't
figure out how to compare checksums, since the time of compilation
and a couple other dynamically generated strings end up in the binary.

--------------020904020401040302050807
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[MODULES]: Don't allow statically declared exports

Add an extern declaration for exported symbols to make the compiler warn
on symbols declared statically.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8648236083e488ff4fc279b66d63b1187e22e558
tree cba9ee372f1056c8cf63cdc6a37a6a761fa490c9
parent 8b21e6d05d6ac0aeb44f5866ab611e2709c2f08e
author Patrick McHardy <kaber@trash.net> Thu, 23 Mar 2006 05:07:39 +0100
committer Patrick McHardy <kaber@trash.net> Thu, 23 Mar 2006 05:07:39 +0100

 include/linux/module.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/module.h b/include/linux/module.h
index 70bd843..d956915 100644
--- a/include/linux/module.h
+++ b/include/linux/module.h
@@ -183,6 +183,7 @@ void *__symbol_get_gpl(const char *symbo
 
 /* For every exported symbol, place a struct in the __ksymtab section */
 #define __EXPORT_SYMBOL(sym, sec)				\
+	extern typeof(sym) sym;					\
 	__CRC_SYMBOL(sym, sec)					\
 	static const char __kstrtab_##sym[]			\
 	__attribute__((section("__ksymtab_strings")))		\

--------------020904020401040302050807--
