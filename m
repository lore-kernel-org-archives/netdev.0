From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: HTB - very bad precision? HFSC works fine! 2.6.28
Date: Thu, 8 Jan 2009 00:02:36 +0200
Message-ID: <200901080002.37223.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:39304 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754746AbZAGWCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 17:02:32 -0500
Received: from [192.168.4.94] (unknown [195.69.208.250])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: denys@visp.net.lb)
	by hosting.visp.net.lb (Postfix) with ESMTPSA id 55D771A4AAD
	for <netdev@vger.kernel.org>; Thu,  8 Jan 2009 00:02:26 +0200 (EET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I notice that our uplink ISP complaining, that we are exceeding our UP rate.

I have configured at HTB 60Mbps, but he is actually receiving bursts up to 
64Mbps.

I tried to lower down HTB values to 57Mbps, and even on Cisco switch interface 
counter(it is averaging 30 seconds of data i guess, to calculate bandwidth) - 
it shows 60.1 - 60.4.

Funny thing, root class in HTB shows 57.1 - 57.3 Mbps. So maybe byte counting 
is wrong in HTB?

I have also "default filter" 
tc filter add dev ${DEV} parent 1:0 protocol ip prio 800 u32 match ip src 
0.0.0.0/0 flowid 1:50

and for HFSC i did also filter for arp.

I tried just to replace HTB plainly by HFSC, and it works perfectly and 
precise. Just what i did - removed prio in class, PARAM variable, and changed 
names by replace 
"htb rate" to "est 1sec 8sec hfsc sc rate"
and
"ceil" to "ul rate"

And 57 and bandwidth on switch went to 56.7 - 56.9, and stays very stable.

P.S. overhead 16 - i tried first without it, then with - no difference.

