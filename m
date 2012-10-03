From: Ken Savage <kens1835@shaw.ca>
Subject: RED tc qdisc not dropping?
Date: Wed, 3 Oct 2012 14:14:50 -0600 (MDT)
Message-ID: <986427880.11879793.1349295290592.JavaMail.root@cds046>
References: <1643425136.11868012.1349294650298.JavaMail.root@cds046>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from idcmail-mo1so.shaw.ca ([24.71.223.10]:50849 "EHLO
	idcmail-mo1so.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752934Ab2JCUPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 16:15:06 -0400
In-Reply-To: <1643425136.11868012.1349294650298.JavaMail.root@cds046>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

I'm running openSUSE 12.2, using the machine as a router/WANsim device.

Previously, I was running an older CentOS installation with a 2.6 kernel,
and my tc-red commands ran just fine, and imposed some bandwidth constraint
to the packets upon egress.  In 3.4.6, this doesn't seem to be the case
any longer.

Without any restrictions, there would be 25-30Mbps of traffic flowing out
the interface -- this is to give you a sense of the data rate.


Now, this said, I did notice that the latest RED code has the 'harddrop'
option that I didn't have under CentOS with kernel 2.6.  So in my attempt
to see ANYTHING happening with 3.4.6, I entered:

tc qdisc add dev eth0 root red limit 40000 min 3000 max 9000 avpkt 1000 burst 5 harddrop probability 1


Issuing 'tc -s -d qdisc show dev eth0', I obtain:

qdisc red 8006: root refcnt 2 limit 40000b min 3000b max 9000b harddrop ewma 2 probability 0.73242 Scell_log 12
 Sent 254028472 bytes 207494 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
  marked 0 early 0 pdrop 0 other 0


All those zeroes seem a little amiss to me  ;)


Any ideas?

Thanks,

Ken Savage
kens1835@shaw.ca
