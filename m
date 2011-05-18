From: Alexey ORISHKO <alexey.orishko@stericsson.com>
Subject: RE: [PATCH v2] CDC NCM: release interfaces fix in unbind()
Date: Wed, 18 May 2011 19:11:37 +0200
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520153E3ACE0774@EXDCVYMBSTM006.EQ1STM.local>
References: <1305662344-28355-1-git-send-email-alexey.orishko@stericsson.com>
 <Pine.LNX.4.44L0.1105181053110.2131-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Alan Stern <stern@rowland.harvard.edu>,
	"gregkh@suse.de" <gregkh@suse.de>,
	"oliver@neukum.org" <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:34137 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932791Ab1ERRL7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2011 13:11:59 -0400
In-Reply-To: <Pine.LNX.4.44L0.1105181053110.2131-100000@iolanthe.rowland.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Alan Stern [mailto:stern@rowland.harvard.edu]
> Sent: Wednesday, May 18, 2011 4:55 PM
> 
> Here and later on, the patch seems to have forgotten about the control
> interface.  Is this deliberate or an oversight?
> 
> Alan Stern

Kernel docs says, that usb_driver_claim_interface() is used by usb
device drivers that need to claim more than one interface. I assume,
it's needed for second interface only. Am I wrong?

NCM driver was partly based on ECM code. I did check existing drivers
for CDC ACM and CDC ECM, which also uses 2 interfaces: master (control)
and data (bulk), but I was unable to find any code, which claims master
interface.

If we need explicitly claim/release master interface (which is *intf
parameter in bind() and unbind()), then cdc-acm and usb_ether drivers
should be updated as well.

I wonder, if Greg or Oliver could provide any comments why master interface
is not claimed in modem/ether drivers, since they are working with the
code for quite a while.

Regards,
Alexey

