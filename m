From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: Re: [-mm PATCH][4/4] net: signed vs unsigned cleanup in net/ipv4/raw.c
Date: Wed, 15 Jun 2005 23:40:12 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0506152338450.3842@dragon.hyggekrogen.localhost>
References: <Pine.LNX.4.62.0506152316060.3842@dragon.hyggekrogen.localhost>
 <20050615.142953.59469324.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: juhl-lkml@dif.dk, yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru,
        jmorris@redhat.com, ross.biro@gmail.com, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050615.142953.59469324.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Jun 2005, David S. Miller wrote:

> From: Jesper Juhl <juhl-lkml@dif.dk>
> Date: Wed, 15 Jun 2005 23:32:22 +0200 (CEST)
> 
> > -	if (length >= sizeof(*iph) && iph->ihl * 4 <= length) {
> > +	if (length >= sizeof(*iph) && (size_t)(iph->ihl * 4) <= length) {
> 
> Would changing the "4" into "4U" kill this warning just the same?
> 
It would.

> I think I'd prefer that.
> 
No problem. Here's a replacement patch nr. 4 : 


Signed-off-by: Jesper Juhl <juhl-lkml@dif.dk>
---

 net/ipv4/raw.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

--- linux-2.6.12-rc6-mm1/net/ipv4/raw.c.with_patch-3	2005-06-15 23:17:23.000000000 +0200
+++ linux-2.6.12-rc6-mm1/net/ipv4/raw.c	2005-06-15 23:37:11.000000000 +0200
@@ -259,7 +259,7 @@ int raw_rcv(struct sock *sk, struct sk_b
 	return 0;
 }
 
-static int raw_send_hdrinc(struct sock *sk, void *from, int length,
+static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 			struct rtable *rt, 
 			unsigned int flags)
 {
@@ -298,7 +298,7 @@ static int raw_send_hdrinc(struct sock *
 		goto error_fault;
 
 	/* We don't modify invalid header */
-	if (length >= sizeof(*iph) && iph->ihl * 4 <= length) {
+	if (length >= sizeof(*iph) && iph->ihl * 4U <= length) {
 		if (!iph->saddr)
 			iph->saddr = rt->rt_src;
 		iph->check   = 0;
