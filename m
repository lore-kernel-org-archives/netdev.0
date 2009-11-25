From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 14688] New: alignment of rx_skb in r8169
 driver
Date: Wed, 25 Nov 2009 15:45:25 -0800 (PST)
Message-ID: <20091125.154525.21136354.davem@davemloft.net>
References: <bug-14688-10286@http.bugzilla.kernel.org/>
	<20091125135507.2160a534.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: meyer@fsr.tu-darmstadt.de, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, romieu@fr.zoreil.com,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47724
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759945AbZKYXpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 18:45:07 -0500
In-Reply-To: <20091125135507.2160a534.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 25 Nov 2009 13:55:07 -0800

>>             (align - 1) & (unsigned long)skb->data
>> 
>> which is wrong. I would suggest the following correction:
>> 
>> pad = align ? align - ((align - 1) & (unsigned long)skb->data) : NET_IP_ALIGN;
>> if (pad == align) pad = 0; // optional
>> skb_reserve(skb, pad);
>> 
>> A patch for r8169.c is provided as attachment.
>> 
> 
> Thanks, but..
> 
> - please always submit patches via email, not via bugzilla. 
>   Documentation/SubmittingPatches goes into some detail.
> 
> - prepare patches as a unified diff, in `patch -p1' form.  It should
>   look like:
 ...
> - Please cc at least the following on the patch:
> 
> 	Francois Romieu <romieu@fr.zoreil.com>
> 	"David S. Miller" <davem@davemloft.net>
> 	netdev@vger.kernel.org
> 
> - Don't forget the changelog and a Singed-off-by:!
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Also a better, more canonical, expression to use to fix this would
be:

	align - ((align - 1) & (unsigned long)skb->data)

or similar.
