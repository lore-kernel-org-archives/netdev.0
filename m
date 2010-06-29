From: James Courtier-Dutton <james.dutton@gmail.com>
Subject: Re: b44: Reset due to FIFO overflow.
Date: Tue, 29 Jun 2010 09:42:38 +0100
Message-ID: <AANLkTilpvEEMH086gZPW3UqWEOWy7Jhtx_Mnqz99vBDb@mail.gmail.com>
References: <AANLkTinwnTw3Yqy3POghliZDRmRYUfJL6Gy67GNNLiYv@mail.gmail.com>
	<1277716394.4235.235.camel@edumazet-laptop>
	<AANLkTik6YBO7bVAy0NjdQGomYBsY-e8PqZ3-Je_vyx7B@mail.gmail.com>
	<1277723471.4235.393.camel@edumazet-laptop>
	<AANLkTikVEwIj2Jjk8YMan4sHDNxpzhK3tlvpuAxYybSI@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:27333 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754025Ab0F2Imk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 04:42:40 -0400
Received: by fg-out-1718.google.com with SMTP id 19so582971fgg.1
        for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 01:42:39 -0700 (PDT)
In-Reply-To: <AANLkTikVEwIj2Jjk8YMan4sHDNxpzhK3tlvpuAxYybSI@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28 June 2010 22:37, James Courtier-Dutton <james.dutton@gmail.com> wrote:
>
> I tried the patch.
> I also tried without the patch, but bypassed the hw reset in the RFO case.
>
> In both cases, the hardware did not recover from the overflow.
> An "ifconfig eth0 down" then "ifconfig eth0 up" was required to bring
> it back to life, I.e. A manual hw reset.
>
> What I did find is that once the RFO state is reached, it is not cleared.
> I think we need to find a way to clear the RFO state.
> The RFO state is cleared after a HW reset.
>
> Kind Regards
>
> James
>

Under further analysis, I have found that RFO is not cleared by a
write to bw32(bp, B44_ISTAT, istat);
whereas most other conditions should be cleared by this.

So, I went searching in the hardware reset functions for when the RFO
was cleared.

I found it:
A call to this:
ssb_device_enable(bp->sdev, 0)
in the b44_chip_reset function is what actually clears the RFO.
So, does anyone have any data sheets on the ssb ?
The ssb looks to me like the DMA engine.

On a more positive note, if we can get the ssb to reset without the
phy resetting, we could have our smooth recovery achieved.

Kind Regards

James
