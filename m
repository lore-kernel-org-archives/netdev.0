From: "Andy Cress" <andy.cress@us.kontron.com>
Subject: pch_gbe:  backport fails to start sending
Date: Thu, 24 May 2012 13:05:05 -0700
Message-ID: <40680C535D6FE6498883F1640FACD44DEA6714@ka-exchange-1.kontronamerica.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.kontron.com ([209.118.138.70]:9284 "EHLO
	mail.us.kontron.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758193Ab2EXUFH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 16:05:07 -0400
Received: from ka-exchange-1.kontronamerica.local ([10.100.2.39]) by mail.us.kontron.com with ESMTP id 8uThdbuasnU8agFG for <netdev@vger.kernel.org>; Thu, 24 May 2012 13:05:06 -0700 (PDT)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Folks,

I now have a different case where the pch_gbe driver needs help.
I have backported the pch_gbe git head (v1.00) to kernel 2.6.32
(RHEL6.2) and when it loads, after the open completes and the link is
up, it fails to start sending and receiving.  
I also took the pch_gbe source which runs fine on 2.6.38 (Fedora 15) and
backported it, and get the same results. 
The much bulkier pch_gbe 0.91-NAPI driver does run on 2.6.32 (RHEL6.2)
but is not maintained.
I also tried backporting the mii.c from the 2.6.38 kernel, but that
didn't help, got the same symptoms.

After adding -DDEBUG to the 1.00 driver, I can see that it seems to get
just DMA Complete interrupts when it should be getting Transmit
complete, etc.   I'm not sure why it gets stuck there.  
Any ideas/input is welcome.  

Andy  

https://sendfile.kontron.com/message/KJKmrf171EhsuvbyhjnXpe 
Attached at this link are two files:  
 pch_gbe-100a.tar.gz = the backported pch_gbe 1.00 head source, includes
patches that were applied.  
 dmesg.tar.gz  =  Some dmesg output from test cases with debug:
   dmesg-pch10a-kern2632-bad.txt = backported 1.00 from git head on
kernel 2.6.32, fails
   dmesg-pch10-kern2632-bad.txt  = backported 1.00 from Fedora 15 on
kernel 2.6.32, fails
   dmesg-pch10-kern2638-good.txt = same 1.00 source from Fedora 15 on
kernel 2.6.38, works
