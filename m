From: Jamal Hadi Salim <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Sat, 08 Jul 2006 10:29:24 -0400
Message-ID: <1152368964.5272.46.camel@jzny2>
References: <1151697554.5270.241.camel@jzny2>
	 <20060630203034.GN14627@postel.suug.ch>
	 <20060630.133348.68039806.davem@davemloft.net>
	 <1151700884.5270.278.camel@jzny2> <20060630211043.GO14627@postel.suug.ch>
	 <1151703097.5270.307.camel@jzny2> <20060630234512.GR14627@postel.suug.ch>
	 <1151722785.5093.51.camel@jzny2> <20060701112833.GS14627@postel.suug.ch>
	 <1151760901.5093.141.camel@jzny2>  <20060708105451.GG14627@postel.suug.ch>
	 <1152368076.5272.39.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-VzFB7wPZ/WSx1IzoGlko"
Cc: kaber@trash.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:22693 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S964848AbWGHO32
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 10:29:28 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FzDoI-0004PS-6v
	for netdev@vger.kernel.org; Sat, 08 Jul 2006 10:29:30 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <1152368076.5272.39.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-VzFB7wPZ/WSx1IzoGlko
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sat, 2006-08-07 at 10:14 -0400, Jamal Hadi Salim wrote:

> I have a dated  patch to mirred (may not apply cleanly) 

Sorry forgot to attach the patch. Attached for real this time;->

> that i believe
> will fix this specific one. Try to see if it also fixes this case you
> have.

I meant i know this works for eth0->eth0 i am not sure if it will fix
your specific case. I need my laptop at the moment ;->
If it does it will be an ok solution but not the best (because it
introduces an unnecessary check for the common case).

cheers,
jamal

--=-VzFB7wPZ/WSx1IzoGlko
Content-Disposition: attachment; filename=mirred-lpath1
Content-Type: text/x-patch; name=mirred-lpath1; charset=utf-8
Content-Transfer-Encoding: 7bit

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 4fcccbd..d8946b3 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -208,6 +208,12 @@ bad_mirred:
 
 	skb2->dev = dev;
 	skb2->input_dev = skb->dev;
+	if (skb2->input_dev == skb2->dev) {
+		if (net_ratelimit())
+			printk(" Mirred: Loop detected to %s\n",skb2->dev->name);
+		goto bad_mirred;
+	}
+
 	dev_queue_xmit(skb2);
 	spin_unlock(&p->lock);
 	return p->action;

--=-VzFB7wPZ/WSx1IzoGlko--

