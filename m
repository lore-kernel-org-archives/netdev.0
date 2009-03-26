From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] net: fix unaligned memory accesses in ASIX
Date: Thu, 26 Mar 2009 09:40:13 +0100
Message-ID: <49CB3F6D.2010508@st.com>
References: <1238050359-28415-1-git-send-email-peppe.cavallaro@st.com> <20090326.010810.23291587.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:44541 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757819AbZCZIkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 04:40:42 -0400
In-Reply-To: <20090326.010810.23291587.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Thu, 26 Mar 2009 07:52:39 +0100
>
>   
>> Move in memory all the frames with an incorrect alignment.
>> This is to prevent unaligned memory accesses into the upper layers.
>> Note 1: this is a penalty for some architecture like SH.
>> Note 2: indeed, this patch restores an old one posted three years ago
>> (http://marc.info/?l=linux-usb-devel&m=116578791817830&w=2).
>>
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>>     
>
> There are some gratuitous (and wrong) changes in here:
>
>   
>> -	u32  header;
>>     
>  ...
>   
>> +	unsigned int header;
>>     
>
> It's a u32 whether you like it or not.  Please don't
> change away from fixed sized types.
>   
I agree... it's a typo error.
> Also isn't there a way we can prefixed what this packet
> offset is going to be?  If so, we can adjust the skb_reserve()
> call the generic USB net code uses.
>   
This was my first test. I had tried to change/adjust headroom but no
success.

Unfortunately, unaligned memory accesses seems to depend on the Asix HW
that packs several incoming frames.
So when these frames are 'unpacked' within the fix-up function, and
pushed to the upper layer, they can have a wrong alignment, indeed.
When no frame is packed all works fine and the IP never works with
unaligned addresses.
I think, the skb_reserve could actually help us, if this last scenario
generated misaligned accesses.
Please let me know if I'm missing something.

Thanks for your feedback!
Regards,
Peppe
> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>   

