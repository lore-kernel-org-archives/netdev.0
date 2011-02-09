From: "Toshiharu Okada" <toshiharu-linux@dsn.okisemi.com>
Subject: Re: [PATCH] pch_gbe: Fix the issue that the receiving data is not normal.
Date: Wed, 9 Feb 2011 13:58:44 +0900
Message-ID: <12CF314023A64E13A83B8E6AEF56D177@hacdom.okisemi.com>
References: <4D50FDAA.1060506@dsn.okisemi.com> <20110208.163522.232741523.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<qi.wang@intel.com>, <yong.y.wang@intel.com>,
	<andrew.chih.howe.khor@intel.com>, <joel.clark@intel.com>,
	<kok.howg.ewe@intel.com>, <tomoya-linux@dsn.okisemi.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 08 Feb 2011 16:35:22 -0800 (PST)
>> Hi Devid
>>
>> I resubmit this patch modified.
>> Please check them.
>
>Your memcpy+memcpy sequences are equivalent to memmove(), please
>use that instead.
>

I use memmove().

>I have to say this function is insanely complicated.  There seems
>to be 16 different ways RX packets are processed.  I can't believe
>that is needs to be like this.

If processing is arranged, There are 4 different ways RX packets are 
processed.

[Case1]
"rx_csum is enable " and
 "NET_IP_ALIGN == 0"

 DMA buffer is used as SKB as it is.

[Case2]
"rx_csum is enable " and
 "NET_IP_ALIGN != 0"

 Because alignment differs, the new_skb is newly allocated, and data is 
copied to new_skb.

[Case3]
"rx_csum is disable " and
 "length < copybreak" or "NET_IP_ALIGN != PCH_GBE_DMA_PADDING"

 Because alignment differs, the new_skb is newly allocated, and data is 
copied to new_skb.
 Padding data is deleted at the time of a copy.

[Case4]
"rx_csum is disable " and
 "length >= copybreak" and "NET_IP_ALIGN == PCH_GBE_DMA_PADDING"

 Padding data is deleted by moving header data.

I rewrite without using skb_copy_flag and skb_padding simply.

Best regards
Toshiharu Okada(OKI semiconductor) 
