From: Radha Mohan <radhamohan_ch@yahoo.com>
Subject: Re: can we reuse an skb
Date: Fri, 19 Jun 2009 12:40:08 +0530 (IST)
Message-ID: <207157.90170.qm@web94803.mail.in2.yahoo.com>
References: <962874.62146.qm@web94813.mail.in2.yahoo.com> <60230E21F17E384C9BF0B9C98D9E3FDC048963D6@sgp-sg-mb02.sgp.agilent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
To: jon_zhou@agilent.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from n14-vm0.bullet.mail.in.yahoo.com ([202.86.5.219]:43547 "HELO
	n14-vm0.bullet.mail.in.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752467AbZFSHWn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jun 2009 03:22:43 -0400
In-Reply-To: <60230E21F17E384C9BF0B9C98D9E3FDC048963D6@sgp-sg-mb02.sgp.agilent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



We may need to modify the part in kernel where kfree_skb() will be called somewhere after copying to user space. Right?

I came to know that Windows NDIS has this type of facility. The NDIS gives back the buffer after copying to application.

I came across a patch made long ago for 2.4.19 citing the same concept
http://www.candelatech.com/oss/napi_tune_2.4.19.patch

-- Mohan



----- Original Message ----
From: "jon_zhou@agilent.com" <jon_zhou@agilent.com>
To: radhamohan_ch@yahoo.com; netdev@vger.kernel.org
Sent: Friday, 19 June, 2009 12:21:45 PM
Subject: RE: can we reuse an skb

I am also thinking about this...

i.e.pcnet32.c
seems the skb will be claimed to be unuseful(mark some bits) in the device driver, than it will be recycled in the softirq handler,

that means unable to reuse it, unless modidy the driver.

Regards,
zhou rui

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Radha Mohan
Sent: Friday, June 19, 2009 2:47 PM
To: netdev@vger.kernel.org
Subject: can we reuse an skb


Hi,

For an ethernet driver, we need to allocate some pool of SKBs for receiving packets. Is there any way we can reuse the same SKBs without the need to re-allocate in atomic every time one has been used up for netif_rx(). 

Any pointers will be helpful.

-- Mohan


      ICC World Twenty20 England '09 exclusively on YAHOO! CRICKET http://cricket.yahoo.com

--
To unsubscribe from this list: send the line "unsubscribe netdev" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html


      ICC World Twenty20 England &#39;09 exclusively on YAHOO! CRICKET http://cricket.yahoo.com

