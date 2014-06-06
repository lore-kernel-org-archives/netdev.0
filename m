From: Zoltan Kiss <zoltan.kiss@schaman.hu>
Subject: Re: [PATCH net] xen-netback: Fix slot estimation
Date: Fri, 06 Jun 2014 11:20:45 +0100
Message-ID: <539195FD.6080606@schaman.hu>
References: <1401802336-25182-1-git-send-email-zoltan.kiss@citrix.com> <20140605.150209.365488173138758921.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, ian.campbell@citrix.com,
	wei.liu2@citrix.com, paul.durrant@citrix.com, linux@eikelenboom.it,
	netdev@vger.kernel.org, david.vrabel@citrix.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:42782 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751722AbaFFKUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 06:20:48 -0400
Received: by mail-we0-f172.google.com with SMTP id k48so2616971wev.17
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 03:20:47 -0700 (PDT)
In-Reply-To: <20140605.150209.365488173138758921.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/14 23:02, David Miller wrote:
> From: Zoltan Kiss<zoltan.kiss@citrix.com>
> Date: Tue, 3 Jun 2014 14:32:16 +0100
>
>> A recent commit (a02eb4 "xen-netback: worse-case estimate in xenvif_rx_action is
>> underestimating") capped the slot estimation to MAX_SKB_FRAGS, but that triggers
>> the next BUG_ON a few lines down, as the packet consumes more slots than
>> estimated.
>> This patch remove that cap, and if the frontend doesn't provide enough slot,
>> put back the skb to the top of the queue and caps rx_last_skb_slots. When the
>> next try also fails, it drops the packet.
>> Capping rx_last_skb_slots is needed because if the frontend never gives enough
>> slots, the ring gets stalled.
>>
>> Signed-off-by: Zoltan Kiss<zoltan.kiss@citrix.com>
> Like David Laight, I do not like this patch at all.
>
> Yes a crash or BUG_ON triggered is bad, but fixing it by deadlocking
> TCP connections (a silent failure) is not an improvement.
>
> I'm not applying this, sorry.
>
Hi,

I haven't wrote it explicitly, but my other patch "xen-netback: Fix 
handling of skbs requiring too many slots" supersedes this one.
