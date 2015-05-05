From: Okash Khawaja <okash.khawaja@gmail.com>
Subject: Re: [PATCH] adm8211: fix checkpatch errors for indentation and new line around switch-case
Date: Tue, 5 May 2015 15:15:16 +0100
Message-ID: <8BB992B7-F9AE-4D3E-92DC-E9154785C92F@gmail.com>
References: <5548B192.8020808@lysator.liu.se> <1430833852.7191.7.camel@perches.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Peter Rosin <peda@lysator.liu.se>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:34528 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993131AbbEEOPd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 10:15:33 -0400
In-Reply-To: <1430833852.7191.7.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On 5 May 2015, at 14:50, Joe Perches <joe@perches.com> wrote:
> 
> On Tue, 2015-05-05 at 14:03 +0200, Peter Rosin wrote:
>>> diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
> []
>>> @@ -1098,14 +1098,18 @@ static void adm8211_hw_init(struct ieee80211_hw *dev)
>>>        pci_read_config_byte(priv->pdev, PCI_CACHE_LINE_SIZE, &cline);
>>> 
>>>        switch (cline) {
> []
>>> +        case  0x8:
>>> +            reg |= (0x1 << 14);
>>> +            break;
>>> +        case 0x16:
>>> +            reg |= (0x2 << 14);
>>> +            break;
>>> +        case 0x32:
>>> +            reg |= (0x3 << 14);
>>> +            break;
>>> +        default:
>>> +            reg |= (0x0 << 14);
>>> +            break;
>>>        }
>>>    }
>> 
>> Those 0x16/0x32 hexadecimal case-selectors looking suspiciously like
>> decimal bits need a comment if they are in fact correct, which I doubt.
> 
> Good spot.
> 
> As it's testing PCI_CACHE_LINE_SIZE,
> they seem very much broken.
> 
> 

Interesting. I'll be happy to fix that bit if someone could guide me on it. Looks like these values should be 0x10, 0x20 instead of 0x16, 0x32 respectively. But I am unable to understand their meaning in this code. 
Thanks