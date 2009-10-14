From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/2] be2net: Add support for next
 generation of BladeEngine device
Date: Wed, 14 Oct 2009 16:33:45 -0700 (PDT)
Message-ID: <20091014.163345.28372235.davem@davemloft.net>
References: <20091014122358.GA11905@serverengines.com>
	<20091014.152402.92489105.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41022
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757322AbZJNXdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 19:33:49 -0400
In-Reply-To: <20091014.152402.92489105.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 14 Oct 2009 15:24:02 -0700 (PDT)

> From: Ajit Khaparde <ajitk@serverengines.com>
> Date: Wed, 14 Oct 2009 17:54:09 +0530
> 
>> Add new PCI ids to support next generation of BladeEnigne device.
>> 
>> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
> 
> Applied.

I have to revert your changes, how did this even build for you?

In file included from drivers/net/benet/be_cmds.c:18:
drivers/net/benet/be.h:45:1: warning: "BE_DEVICE_ID1" redefined
drivers/net/benet/be.h:44:1: warning: this is the location of the previous definition
drivers/net/benet/be.h:48:1: warning: "OC_DEVICE_ID2" redefined
drivers/net/benet/be.h:47:1: warning: this is the location of the previous definition

Well, obviously, since in your patch:

 #define BE_VENDOR_ID 		0x19a2
 #define BE_DEVICE_ID1		0x211
+#define BE_DEVICE_ID1		0x221
 #define OC_DEVICE_ID1		0x700
 #define OC_DEVICE_ID2		0x701
+#define OC_DEVICE_ID2		0x710

drivers/net/benet/be.h:56: error: 'OC_DEVICE_ID3' undeclared (first use in this function)
drivers/net/benet/be.h:58: error: 'BE_DEVICE_ID2' undeclared (first use in this function)

The mistake is obvious, and you provably didn't even compile check
these changes.

How can I possibly take your patches seriously when it is clear how
incredibly careless you are being here?
