From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH Re: udp weirdness
Date: Tue, 1 Oct 2002 05:51:28 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210010537230.17694-100000@shell.cyberus.ca>
References: <20021001063557.GA331@hookipa>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Lemoine <Eric.Lemoine@ens-lyon.fr>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lemoine <Eric.Lemoine@sun.com>
In-Reply-To: <20021001063557.GA331@hookipa>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




On Tue, 1 Oct 2002, Eric Lemoine wrote:

> Jamal,
>
> Have you posted the right patch?

;-> I dont know what happened; patch below is what i was trying to post
I deleted all the old patches this time to make sure ;->

> I see that sk->protinfo.af_inet.recverr is
> still around. Here follows the patch that I think is the correct one.
> Please confirm. Thx.
>

Yes it is correct but was missing one more bit from v6 added below.
Alexey/Dave this is the correct version ;->

cheers,
jamal

--- linux/net/ipv4/ip_output.c	2002/09/29 08:50:36     1.1
+++ linux/net/ipv4/ip_output.c	2002/09/30 09:11:15
@@ -603,8 +603,8 @@
 		err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
 			      skb->dst->dev, output_maybe_reroute);
 		if (err) {
-			if (err > 0)
-				err = sk->protinfo.af_inet.recverr ? net_xmit_errno(err) : 0;
+			if (err > 0)
+				 err = net_xmit_errno(err);
 			if (err)
 				goto error;
 		}
@@ -713,8 +713,8 @@

 	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
 		      output_maybe_reroute);
-	if (err > 0)
-		err = sk->protinfo.af_inet.recverr ? net_xmit_errno(err) : 0;
+	if (err > 0)
+			err = net_xmit_errno(err);
 	if (err)
 		goto error;
 out:
--- linux/net/ipv6/ip6_output.c	2002/09/30 18:30:52     1.1
+++ linux/net/ipv6/ip6_output.c	2002/09/30 18:31:30
@@ -684,7 +684,7 @@
 out:
 	ip6_dst_store(sk, dst, fl->nl_u.ip6_u.daddr == &np->daddr ? &np->daddr : NULL);
 	if (err > 0)
-		err = np->recverr ? net_xmit_errno(err) : 0;
+		err = net_xmit_errno(err);
 	return err;
 }
