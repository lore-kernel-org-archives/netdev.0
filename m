From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: bnx2, 2.6.29, smp_affinity strangeness
Date: Sun, 29 Mar 2009 03:47:58 +0200
Message-ID: <200903290447.58338.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:41839 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbZC2Br5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2009 21:47:57 -0400
Received: from adminos.visp.net.lb (unknown [195.69.208.252])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: denys@visp.net.lb)
	by hosting.visp.net.lb (Postfix) with ESMTPSA id 5A9931A4B86
	for <netdev@vger.kernel.org>; Sun, 29 Mar 2009 04:47:50 +0300 (EEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

While running bnx2 tried to assign affinity to network card and ... failed.

Here it is:
globax2 ~ # cat /proc/interrupts |grep 
eth1;cat /proc/irq/97/smp_affinity ;sleep 4;cat /proc/interrupts |grep eth1
 97:    5637762    5637764    5637745    5637674    5637815    5637842    
5637795    5637839   PCI-MSI-edge      eth1
10
 97:    5641756    5641754    5641739    5641669    5641809    5641836    
5641789    5641833   PCI-MSI-edge      eth1

As you see, smp_affinity set to CPU4 (5th CPU if count from 1), but interrupts 
is still happening on all CPU's.

Meanwhile i found more strange things:

I did ifconfig to eth0 up
in dmesg got 
[ 4855.804365] bnx2 0000:05:00.0: irq 98 for MSI/MSI-X
[ 4855.923017] bnx2: eth0: using MSI

default_smp_affinity was 0xf (first 4 CPU)

and got:
 98:         66         73         67         67          0          0          
0          0   PCI-MSI-edge      eth0

but if i try to change smp_affinity while it is running - it wont change 
anything.

If i bring interface down, i will see strange entry
 98:         90         90         86         88          0          0          
0          0      none-<NULL>

Now i have entry in /proc/irq/98/ , so while it is down i change affinity to 
10. Voila, i bring it up, and affinity working correct.

 98:         90         90         86         88         51          0          
0          0   PCI-MSI-edge      eth0
 98:         90         90         86         88        129          0          
0          0   PCI-MSI-edge      eth0


Is it correct that i am able to change IRQ affinity only when interface down?
On other cards i can change it "on fly".

