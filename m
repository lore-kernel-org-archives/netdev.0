From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] fib: Use const struct nl_info * in rtmsg_fib
Date: Thu, 17 Oct 2013 13:34:11 -0700
Message-ID: <1382042051.22110.146.camel@joe-AO722>
References: <CAKfDRXizw1TaK-oHrAQv8Hi80gKiUHjQ6d21o3MOQpuVkcXSow@mail.gmail.com>
	 <1382028894-14236-1-git-send-email-kristian.evensen@gmail.com>
	 <1382030610.22110.112.camel@joe-AO722>
	 <CAKfDRXjctGkcqSt9cM=iWbckLt4=7n8434WAA8rr4_cEofEO=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0082.hostedemail.com ([216.40.44.82]:55264 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758867Ab3JQUeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 16:34:15 -0400
In-Reply-To: <CAKfDRXjctGkcqSt9cM=iWbckLt4=7n8434WAA8rr4_cEofEO=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rtmsg_fib function doesn't modify this argument so mark
it const.

Signed-off-by: Joe Perches <joe@perches.com>
---
On Thu, 2013-10-17 at 22:14 +0200, Kristian Evensen wrote:
> Hi,

Hi Kristian.

> On Thu, Oct 17, 2013 at 7:23 PM, Joe Perches <joe@perches.com> wrote:
> >
> > Perhaps this memset should be moved into the
> > list_for_each_entry_safe loop where cfg is used.
> 
> Thanks for your comment. I decided to put it there to avoid calling it
> for each route that will be deleted. Since the struct is never
> modified (only read in fib_rtmsg()) and we have the rtnl_lock, I
> assumed it to be safe. Are there cases where this assumption is wrong?

I didn't look too hard.
I just glanced at the prototype and saw it wasn't const.

If rtmsg_fib() doesn't modify cfg (and it doesn't seem to)
then the prototype and function should be marked const.

And you're right, it doesn't need to be inside the loop.

cheers, Joe

 net/ipv4/fib_lookup.h    | 2 +-
 net/ipv4/fib_semantics.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index af0f14a..50cfb3e 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -32,7 +32,7 @@ extern int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 			 int dst_len, u8 tos, struct fib_info *fi,
 			 unsigned int);
 extern void rtmsg_fib(int event, __be32 key, struct fib_alias *fa,
-		      int dst_len, u32 tb_id, struct nl_info *info,
+		      int dst_len, u32 tb_id, const struct nl_info *info,
 		      unsigned int nlm_flags);
 extern struct fib_alias *fib_find_alias(struct list_head *fah,
 					u8 tos, u32 prio);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index d5dbca5..e63f47a 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -380,7 +380,7 @@ static inline size_t fib_nlmsg_size(struct fib_info *fi)
 }
 
 void rtmsg_fib(int event, __be32 key, struct fib_alias *fa,
-	       int dst_len, u32 tb_id, struct nl_info *info,
+	       int dst_len, u32 tb_id, const struct nl_info *info,
 	       unsigned int nlm_flags)
 {
 	struct sk_buff *skb;
