From: David Miller <davem@davemloft.net>
Subject: Re: STMMAC: sleep inside atomic
Date: Mon, 06 Sep 2010 13:08:55 -0700 (PDT)
Message-ID: <20100906.130855.112605035.davem@davemloft.net>
References: <4C8231E8.5090001@gmail.com>
	<4C84B8A8.5080503@st.com>
	<4C854013.70704@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: jirislaby@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34618
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751219Ab0IFUIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 16:08:37 -0400
In-Reply-To: <4C854013.70704@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jirislaby@gmail.com>
Date: Mon, 06 Sep 2010 21:25:07 +0200

> On 09/06/2010 11:47 AM, Peppe CAVALLARO wrote:
>> On 9/4/2010 1:47 PM, Jiri Slaby wrote:
>>> stanse found that the driver may sleep inside atomic:
>>> stmmac_resume
>>>   -> spin_lock
>>>   -> stmmac_open
>>>     -> request_irq
>>>     -> kzalloc(..., GFP_KERNEL);
>>>     -> init_dma_desc_rings
>>>       -> kmalloc(..., GFP_KERNEL);
>>>     -> and many others...
>>>   -> spin_unlock
>>>
>>> Could you fix that?
>>>
>> Yes I could ...  kmalloc(...,GFP_KERNEL) can sleep!
>> I will fix the spinlock usage in the driver's resume function and send a
>> patch to the mailing list asap.
> 
> Hi, I hope you'll carbon-copy me. It's not only kmalloc, request_irq
> and others may sleep too.

Guiseppe CAVALLARO posted a patch that seems to be a working one,
please see his netdev posting.
