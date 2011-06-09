From: Joe Buehler <aspam@cox.net>
Subject: Re: source route ignored in favor of local interface
Date: Thu, 09 Jun 2011 12:27:43 -0400
Message-ID: <4DF0F47F.1080502@cox.net>
References: <loom.20110301T154947-689@post.gmane.org> <4D6D4370.5040308@genband.com> <4D6D49AE.2030303@cox.net> <4D6E928D.6030806@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Chris Friesen <chris.friesen@genband.com>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eastrmfepi207.cox.net ([68.230.241.211]:60213 "EHLO
	eastrmfepi207.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346Ab1FIQfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 12:35:34 -0400
In-Reply-To: <4D6E928D.6030806@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:

> You can do this on more modern kernels (2.6.36 and later definately
> works..not sure
> about earlier).
> 
>         ip rule add pref 512 lookup local
>         ip rule del pref 0 lookup local
> 

The kernel change for this in later kernels was simple enough -- there
is a flag that prevents deletion of the "local" table rule, just remove
the flag.  Here is a patch for 2.6.24.7.  The patch for 2.6.27.7 (I am
using both versions) is almost the same.

--- old/net/ipv4/fib_rules.c	2008-01-24 17:58:37.000000000 -0500
+++ new/net/ipv4/fib_rules.c	2011-06-08 14:01:19.000000000 -0400
@@ -297,7 +297,7 @@
 	int err;

 	err = fib_default_rule_add(&fib4_rules_ops, 0,
-				   RT_TABLE_LOCAL, FIB_RULE_PERMANENT);
+				   RT_TABLE_LOCAL, 0);
 	if (err < 0)
 		return err;
 	err = fib_default_rule_add(&fib4_rules_ops, 0x7FFE,
--- old/net/ipv6/fib6_rules.c	2008-01-24 17:58:37.000000000 -0500
+++ new/net/ipv6/fib6_rules.c	2011-06-08 14:01:34.000000000 -0400
@@ -256,7 +256,7 @@
 	int err;

 	err = fib_default_rule_add(&fib6_rules_ops, 0,
-				   RT6_TABLE_LOCAL, FIB_RULE_PERMANENT);
+				   RT6_TABLE_LOCAL, 0);
 	if (err < 0)
 		return err;
 	err = fib_default_rule_add(&fib6_rules_ops, 0x7FFE, RT6_TABLE_MAIN, 0);


Joe Buehler
