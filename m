From: Doug Kehn <rdkehn@yahoo.com>
Subject: skb_bond(): Let master dev see skb
Date: Thu, 3 Jul 2008 06:38:57 -0700 (PDT)
Message-ID: <19562.56527.qm@web52008.mail.re2.yahoo.com>
Reply-To: rdkehn@yahoo.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52008.mail.re2.yahoo.com ([206.190.48.57]:21871 "HELO
	web52008.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756247AbYGCNi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 09:38:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I was looking at writing a net driver for a Marvell switch chip attached 
to an Ethernet MAC on a SoC.  The driver would be similar to the bonding 
driver except that it would bond to a single slave (the SoC Ethernet 
driver) and export multiple net devs.  The idea is to steer frames to a 
physical port on the switch by adding a 4-byte trailer to the frame.  The 
switch will use the trailer to determine the port to send the frame.  The 
switch also strips the trailer before sending.  On packet reception, the 
switch adds the 4-byte trailer to the frame indicating the physical port 
the frame was received.  The master needs to see the skb in order to 
determine the actual dev to associate with the skb and to strip off the 
4-byte trailer.

I was thinking of adding a function pointer to net_dev to allow a master 
to see the skb and have skb_bond() call the function if the pointer has 
been initialized.  skb_bond would function as is if the pointer is not 
initialized.

Is there a better way to accomplish this or is this approach reasonable?


Thanks,
...doug



      
