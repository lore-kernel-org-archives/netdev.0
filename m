From: jamal <hadi@cyberus.ca>
Subject: Re: udp weirdness
Date: Mon, 30 Sep 2002 08:23:51 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0209300822150.11444-100000@shell.cyberus.ca>
References: <Pine.GSO.4.30.0209300753550.11444-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Lemoine <Eric.Lemoine@ens-lyon.fr>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lemoine <Eric.Lemoine@sun.com>
In-Reply-To: <Pine.GSO.4.30.0209300753550.11444-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Mon, 30 Sep 2002, jamal wrote:

> was to use sk->protinfo.af_inet.recverr only in the case of all is
> clean from the device layer.

Of course if you want to say sk->protinfo.af_inet.recverr is higher
priority then the patch becomes;->

--- ip_output.c	2002/09/29 08:50:36	1.1
+++ ip_output.c	2002/09/30 06:38:32
@@ -603,8 +603,9 @@
 		err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
 			      skb->dst->dev, output_maybe_reroute);
 		if (err) {
-			if (err > 0)
-				err = sk->protinfo.af_inet.recverr ? net_xmit_errno(err) : 0;
+			if (err > 0) {
+				 err = sk->protinfo.af_inet.recverr ? sk->protinfo.af_inet.recverr:net_xmit_errno(err);
+			}
 			if (err)
 				goto error;
 		}
@@ -713,8 +714,9 @@

 	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
 		      output_maybe_reroute);
-	if (err > 0)
-		err = sk->protinfo.af_inet.recverr ? net_xmit_errno(err) : 0;
+	if (err > 0) {
+			err = sk->protinfo.af_inet.recverr ? sk->protinfo.af_inet.recverr:net_xmit_errno(err);
+	}
 	if (err)
 		goto error;
 out:
