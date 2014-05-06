From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: Re: [PATCH] jme: Fix DMA unmap warning
Date: Wed, 7 May 2014 02:34:55 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1405070230210.1428@ws.cisco>
References: <1399315907-27148-1-git-send-email-nhorman@tuxdriver.com> <alpine.LNX.2.03.1405070152550.22076@ws.cisco> <20140506205046.GC2858@hmsreliant.think-freely.org> <20140506.165347.1104086045678188867.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nhorman@tuxdriver.com, _govind@gmx.com, netdev@vger.kernel.org,
	cooldavid@cooldavid.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:62801 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755023AbaEFVF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2014 17:05:59 -0400
In-Reply-To: <20140506.165347.1104086045678188867.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 6 May 2014, David Miller wrote:

> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Tue, 6 May 2014 16:50:46 -0400
>
>>>> +		ctxbi = txbi + ((startidx + j + 2) & (mask));
>>>> +		pci_unmap_page(jme->pdev,
>>>> +				ctxbi->mapping,
>>>> +				ctxbi->len,
>>>> +				PCI_DMA_TODEVICE);
>>>> +
>>>> +				ctxbi->mapping = 0;
>>>> +				ctxbi->len = 0;
>>>
>>> Alignment, a tab from 'for'
>> Not sure what you mean by this, I don't see any alignment errors above, or in my
>> tree.  Checkpatch also claims its clean.
>
> Indeed it is indented correctly, the "+" at the beginning of the line in
> the patch makes it look like it's not, but it is.
>

Hmm. This is how it looked when I applied the patch.
http://i.imgur.com/ZdjqJ3d.png

ctxbi->mapping = 0;
ctxbi->len = 0;

is aligned to '(' of pci_unmap_page. But these two statements are not arg of
the function. Shouldn't it be aligned along pci_unmap_page and not '('

Govind
