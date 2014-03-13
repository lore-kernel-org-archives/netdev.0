From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v7 4/9] xen-netback: Introduce TX grant mapping
Date: Thu, 13 Mar 2014 17:43:35 +0000
Message-ID: <5321EE47.5070709@citrix.com>
References: <1394142511-14827-1-git-send-email-zoltan.kiss@citrix.com>		 <1394142511-14827-5-git-send-email-zoltan.kiss@citrix.com>	 <1394706812.25873.28.camel@kazak.uk.xensource.com>	 <5321B006.9070608@citrix.com> <1394718990.25873.70.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:13047 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754325AbaCMRni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 13:43:38 -0400
In-Reply-To: <1394718990.25873.70.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/03/14 13:56, Ian Campbell wrote:
> On Thu, 2014-03-13 at 13:17 +0000, Zoltan Kiss wrote:
>> On 13/03/14 10:33, Ian Campbell wrote:
>>> On Thu, 2014-03-06 at 21:48 +0000, Zoltan Kiss wrote:
>>>
>>>> +				netdev_err(vif->dev,
>>>> +					   "Page still granted! Index: %x\n",
>>>> +					   i);
>>>> +			i = -1;
>>>
>>> Should there not be a break here? Otherwise don't we restart the for
>>> loop from 0 again? If that is intentional then a comment would be very
>>> useful.
>> Yes, that's intentional, we shouldn't exit this loop until everything is
>> unmapped. An i-- would be fine as well. I will put a comment there.
>
> Yes please do, it's very non-obvious what is going on. I'm almost
> inclined to suggest that this is one of the few places where a goto
> retry might be appropriate.
>
> Can you also add a comment saying what is doing the actual unmap work
> which we are waiting for here since it is not actually part of the loop.
> Might a barrier be needed to ensure we see that work happening?
I don't think a barrier is necessary here, if this function ran into 
!NETBACK_INVALID_HANDLE, it just starts again the checking.

On 13/03/14 13:17, Zoltan Kiss wrote:>>
 >> [...]
 >>> +    /* Btw. already unmapped? */
 >>
 >> What does this comment mean? Is it a fixme? An indicator that
 >> xenvif_grant_handle_reset is supposed to handle this case or something
 >> else?
 > It comes from the time when xenvif_grant_handle_reset was not a
 > standalone function. Yes, it refers to the check in the beginning of
 > that function, and it should go there.

I ended up removing that comment, the error message in the function 
tells the same.

Zoli
