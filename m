From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] net: fix unaligned memory accesses in ASIX
Date: Thu, 26 Mar 2009 11:01:50 +0100
Message-ID: <49CB528E.9060505@st.com>
References: <1238050359-28415-1-git-send-email-peppe.cavallaro@st.com>	<20090326.010810.23291587.davem@davemloft.net>	<49CB3F6D.2010508@st.com> <20090326.020018.26561577.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:50072 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755876AbZCZKCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 06:02:12 -0400
In-Reply-To: <20090326.020018.26561577.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Thu, 26 Mar 2009 09:40:13 +0100
>
>   
>> Unfortunately, unaligned memory accesses seems to depend on the Asix HW
>> that packs several incoming frames.
>> So when these frames are 'unpacked' within the fix-up function, and
>> pushed to the upper layer, they can have a wrong alignment, indeed.
>> When no frame is packed all works fine and the IP never works with
>> unaligned addresses.
>> I think, the skb_reserve could actually help us, if this last scenario
>> generated misaligned accesses.
>> Please let me know if I'm missing something.
>>     
>
> The unpacker is taking a set of packet(s) in a USB buffer
> and copying them into SKB's right?  That code should be where
> the offset is checked in the child driver, and adjustments
> made as-needed.
>
> This code seems to call the downstream driver callback after
> the damage is done.  I think it needs to ask the driver to
> look for and indicate the offset before the building of the
> SKB is performed.
>   
I understand your point of view.

In any case, at first glance, I understand that the urb->transfer_buffer
directly points to the preallocated skb data.
These are filled by the HWs. I mean, the buffers are treated by the HW.
So I guess, the meaning of the rx_fixup functions is just to solve this
kind of situations.
In fact, each usb net driver has an own fixup code according to their HW
specifications.

Peppe
