From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] fix skb leak in af_irda.c
Date: Tue, 4 Nov 2003 16:29:30 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031105002930.GA16055@bougret.hpl.hp.com>
References: <20031101051931.GI3705@conectiva.com.br> <20031104224201.GA15041@bougret.hpl.hp.com> <20031104153042.416b9c36.davem@redhat.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@conectiva.com.br, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031104153042.416b9c36.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Nov 04, 2003 at 03:30:42PM -0800, David S. Miller wrote:
> On Tue, 4 Nov 2003 14:42:01 -0800
> Jean Tourrilhes <jt@bougret.hpl.hp.com> wrote:
> 
> > On Sat, Nov 01, 2003 at 03:19:31AM -0200, Arnaldo Carvalho de Melo wrote:
> > > Hi David, Jean,
> > > 
> > > 	Please apply.
> > 
> > 	Hum... It looks as if it didn't made into the kernel. Ok, I'll
> > add that in my patch queue and push that for you ;-)
> 
> It isn't in because I was waiting for an acknowledgment
> from you Jean :-)

	*Ahem*... Sorry about that...
	I personally would prefer the following patch. The difference
is mostly cosmetic. Tested with 2.6.0-test9. Anyway, both patches are
obviously correct.
	Thanks for keeping on top of those things...

	Jean

---------------------------------------------------------

diff -u -p linux/net/irda/af_irda.d4.c linux/net/irda/af_irda.c
--- linux/net/irda/af_irda.d4.c	Tue Nov  4 14:37:25 2003
+++ linux/net/irda/af_irda.c	Tue Nov  4 14:39:10 2003
@@ -188,8 +188,10 @@ static void irda_connect_confirm(void *i
 	IRDA_DEBUG(2, "%s(%p)\n", __FUNCTION__, self);
 
 	sk = self->sk;
-	if (sk == NULL)
+	if (sk == NULL) {
+		dev_kfree_skb(skb);
 		return;
+	}
 
 	dev_kfree_skb(skb);
 	// Should be ??? skb_queue_tail(&sk->sk_receive_queue, skb);
@@ -248,8 +250,10 @@ static void irda_connect_indication(void
 	IRDA_DEBUG(2, "%s(%p)\n", __FUNCTION__, self);
 
 	sk = self->sk;
-	if (sk == NULL)
+	if (sk == NULL) {
+		dev_kfree_skb(skb);
 		return;
+	}
 
 	/* How much header space do we need to reserve */
 	self->max_header_size = max_header_size;
