From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: STMMAC: sleep inside atomic
Date: Mon, 06 Sep 2010 21:25:07 +0200
Message-ID: <4C854013.70704@gmail.com>
References: <4C8231E8.5090001@gmail.com> <4C84B8A8.5080503@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>
To: Peppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47674 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883Ab0IFTZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 15:25:12 -0400
Received: by fxm13 with SMTP id 13so2614855fxm.19
        for <netdev@vger.kernel.org>; Mon, 06 Sep 2010 12:25:11 -0700 (PDT)
In-Reply-To: <4C84B8A8.5080503@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06/2010 11:47 AM, Peppe CAVALLARO wrote:
> On 9/4/2010 1:47 PM, Jiri Slaby wrote:
>> stanse found that the driver may sleep inside atomic:
>> stmmac_resume
>>   -> spin_lock
>>   -> stmmac_open
>>     -> request_irq
>>     -> kzalloc(..., GFP_KERNEL);
>>     -> init_dma_desc_rings
>>       -> kmalloc(..., GFP_KERNEL);
>>     -> and many others...
>>   -> spin_unlock
>>
>> Could you fix that?
>>
> Yes I could ...  kmalloc(...,GFP_KERNEL) can sleep!
> I will fix the spinlock usage in the driver's resume function and send a
> patch to the mailing list asap.

Hi, I hope you'll carbon-copy me. It's not only kmalloc, request_irq
and others may sleep too.

> Many thanks to have found it.

welcome,
-- 
js
