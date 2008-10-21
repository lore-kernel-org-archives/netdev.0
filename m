From: =?ISO-8859-1?Q?Alex_Villac=ED=ADs_Lasso?=
	<avillaci@ceibo.fiec.espol.edu.ec>
Subject: Regression: Recent networking (qdisc?) patches break irda_get_next_speed()
Date: Tue, 21 Oct 2008 13:20:02 -0500
Message-ID: <48FE1D52.6080903@ceibo.fiec.espol.edu.ec>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-200-93-199-98.telconet.net ([200.93.199.98]:42514 "EHLO
	elastix.palosanto.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751890AbYJUSnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 14:43:33 -0400
Received: from srv64.palosanto.com (unknown [192.168.1.64])
	by elastix.palosanto.com (Postfix) with ESMTP id B38521B08FAB
	for <netdev@vger.kernel.org>; Tue, 21 Oct 2008 13:20:17 -0500 (ECT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A regression has been introduced in 2.6.27 in the networking code, which 
breaks the irda_get_next_speed() function used by some IrDA drivers, 
including ks959-sir, written by me. I have filed a bug at:

http://bugzilla.kernel.org/show_bug.cgi?id=11795

to keep track of this. I am still performing bisection to locate the 
exact commit that broke the code, but the bug involves an overwriting of 
the beginning of a structure with extraneous data that makes the 
LAP_MAGIC check fail. I have tried searching the netdev archives, but 
there is no mention at all of regressions caused by this code. Milan 
Plzik at irda-users mentions the same problem affecting pxaficp_ir, and 
mentions recent qdisc patches as possible culprits.  Vasily Khoruzhick 
reported this bug at irda-users, and a quick hack (not a proper fix) 
proposed by him involves padding "struct irda_skb_cb" with 4 bytes at 
the beginning of the structure to move everything else past the buggy 
scribbling.


This URL contains an early reference to what is possibly this same bug
http://sourceforge.net/mailarchive/forum.php?thread_name=1223138254.21553.7.camel%40localhost&forum_name=irda-users

-- 
perl -e '$x=2.4;print sprintf("%.0f + %.0f = %.0f\n",$x,$x,$x+$x);'

