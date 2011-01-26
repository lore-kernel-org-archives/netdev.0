From: "Mills, Tony" <tony.mills@jagex.com>
Subject: RE: bnx2 cards intermittantly going offline
Date: Wed, 26 Jan 2011 12:44:52 +0000
Message-ID: <6DD3782C33561D44B47071B09946026405F65F9333@exchange1>
References: <6DD3782C33561D44B47071B09946026405F63853AB@exchange1>
 <1295373358.8131.4.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.jagex.com ([212.44.19.211]:5894 "EHLO mx2.jagex.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753125Ab1AZMo5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 07:44:57 -0500
In-Reply-To: <1295373358.8131.4.camel@HP1>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Thanks for your response. 

I have done some further investigation and found that we have had a massive amount of interrupts occurring on our Broadcom cards, i have set the affinity for irq 36 and 48 to run on the first two vcpu's on the box and the java processes to run on the others. I have also replaced the debian bnx2 driver with the latest from the Broadcom website and made the rx ring buffer to 4080, this has stopped a multiplexed server running at 1.6 cycles per second from missing cycles due to interrupts on the interface and allowing much better processing time, and the ring buffer up at 4080 stops the rx_fw_discards i was seeing periodically, (even upping that to 1020 or 2040 did not sort the issue but the maximum setting from the Broadcom driver does. 

I am now monitoring the system to see if the card ever becomes unresponsive. But i do have a question. 

If i setup the smp_affinity with a mask of cpu 0 and 1 (the first two on the box) for the APIC-fasteoi irq's for the Ethernet devices, it appears that the kernel does not balance and will continue to use the same cpu to do the interrupts even though there is processing power on the other one. Is this a known issue or am i doing something wrong?

Can i add it's on an dell r610 with a 12 core intel Xeon X5680, this shows up as 24 vcpu's. 

Best Regards

Tony Mills


-----Original Message-----
From: Michael Chan [mailto:mchan@broadcom.com] 
Sent: 18 January 2011 17:56
To: Mills, Tony
Cc: netdev@vger.kernel.org
Subject: Re: bnx2 cards intermittantly going offline


On Tue, 2011-01-18 at 02:54 -0800, Mills, Tony wrote:
> Last night i setup a machine to monitor overnight and at 3:52 this
> morning it became unresponsive. 
> 

When it becomes unresponsive, please send some packets to the NIC (such
as ping) and monitor statistics with ethtool -S.  See if the packets are
being received or discarded.  Also, run tcpdump on the machine to see if
the packets are properly received by the stack.  Thanks.


-- 
IMPORTANT NOTICE

The sender does not guarantee that this message, including any attachment, is secure
or virus free. Also, it is confidential and may be privileged or otherwise protected
from disclosure. If you are not the intended recipient, do not disclose or copy it
or its contents. Please telephone or email the sender and delete the message
entirely from your system.
Jagex Limited is a company registered in England & Wales with company number
03982706 and a registered office at St John's Innovation Centre, Cowley Road, 
Cambridge, CB4 0WS, UK.
