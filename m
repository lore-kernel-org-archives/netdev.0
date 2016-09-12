From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: Minimum MTU Mess
Date: Mon, 12 Sep 2016 11:59:41 +0900
Message-ID: <08e44341-cfcd-5644-8e23-f7348de376b2@miraclelinux.com>
References: <20160902170742.GA17677@redhat.com>
 <20160906.165529.496766310703537877.davem@davemloft.net>
 <20160907195356.GX33916@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34624 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932336AbcILC7p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Sep 2016 22:59:45 -0400
Received: by mail-pf0-f174.google.com with SMTP id p64so47799097pfb.1
        for <netdev@vger.kernel.org>; Sun, 11 Sep 2016 19:59:44 -0700 (PDT)
In-Reply-To: <20160907195356.GX33916@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Jarod Wilson wrote:
> On Tue, Sep 06, 2016 at 04:55:29PM -0700, David Miller wrote:
>> From: Jarod Wilson <jarod@redhat.com>
>> Date: Fri, 2 Sep 2016 13:07:42 -0400
>>
>>> In any case, the number of "mtu < 68" and "#define FOO_MIN_MTU 68", or
>>> variations thereof, under drivers/net/ is kind of crazy.
>>
>> Agreed, we can have a default and let the different cases provide
>> overrides.
>>
>> Mostly what to do here is a function of the hardware though.
> 
> So I've been tinkering with this some, and it looks like having both
> centralized min and max checking could be useful here. I'm hacking away at
> drivers now, but the basis of all this would potentially look about like
> the patch below, and each device would have to set dev->m{in,ax}_mtu one
> way or another. Drivers using alloc_etherdev and/or ether_setup would get
> the "default" values, and then they can be overridden. Probably need
> something to make sure dev->max_mtu isn't set to 0 though...
> 
> Possibly on the right track here, or might there be a better way to
> approach this?
> 
> diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
> index 117d02e..864d6f2 100644
> --- a/include/uapi/linux/if_ether.h
> +++ b/include/uapi/linux/if_ether.h
> @@ -35,6 +35,8 @@
>  #define ETH_FRAME_LEN	1514		/* Max. octets in frame sans FCS */
>  #define ETH_FCS_LEN	4		/* Octets in the FCS		 */
>  
> +#define ETH_MIN_MTU	68		/* Min IPv4 MTU per RFC791	*/
> +
>  /*
>   *	These are the defined Ethernet Protocol ID's.
>   */

Why don't we disable IPv4 if the MTU is lower than this value
as we do for IPv6?

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
