From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 1/1] net sched: Added the TC_LINKLAYER_CUSTOM linklayer
 type
Date: Wed, 5 Jul 2017 09:01:33 +0200
Message-ID: <20170705070133.GA1850@nanopsycho>
References: <20170704001426.9268-1-Robert.McCabe@rockwellcollins.com>
 <20170704054832.GA1865@nanopsycho>
 <CAA0ESdoOd9V_=NqUtM4Nmxvb+tz+AiMAfXvS6ndNLaif59+WUg@mail.gmail.com>
 <20170704153450.GB1865@nanopsycho>
 <20170704154023.GC1865@nanopsycho>
 <CAA0ESdojQfya_PTo=hJeCX1U6ReJ8L2sBra9wUW4LfGwzLYW_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Robert McCabe <robert.mccabe@rockwellcollins.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:36471 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752290AbdGEHBg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 03:01:36 -0400
Received: by mail-wm0-f43.google.com with SMTP id 62so213151924wmw.1
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 00:01:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAA0ESdojQfya_PTo=hJeCX1U6ReJ8L2sBra9wUW4LfGwzLYW_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 04, 2017 at 07:12:47PM CEST, robert.mccabe@rockwellcollins.com wrote:
>>>Even so, the kernel patch you sent does not make any sense. Introduces
>>>TC_LINKLAYER_CUSTOM but does not use it.
>
>I needed to add this to the tc_link_layer enum in my iproute2 patch
>(https://patchwork.ozlabs.org/patch/784165/)
>
>enum tc_link_layer {
>      TC_LINKLAYER_UNAWARE, /* Indicate unaware old iproute2 util */
>      TC_LINKLAYER_ETHERNET,
>      TC_LINKLAYER_ATM,
>   + TC_LINKLAYER_CUSTOM,
> };
>
>I originally wasn't aware that this file was shared with the kernel --
>my original patch received the comment from Eric Dumazet
>
>    You can not do this : This file is coming from the kernel
>     ( include/uapi/linux/pkt_sched.h )

Correct.


>
>So I opted to make the corresponding change to the pkt_sched.h file in
>the kernel.

I'm not sure how should I put this, but you are adding enum value and
you are not using it in kernel! That is wrong. Whenever you add new
value to UAPI, it has to have a point. Please see:

$ git grep TC_LINKLAYER_


>But looking at it further, I am confused as to why this tc_link_layer even needs
>to exist in the kernel anyway,  It is only used in net/sched for calculating the
>size (via stab) and rate (via rtab) translations; however, these
>translations are
>already specified with in the form of the stab and rtab themselves (these are
>calculated in userspace).
>
>I think -- in a perfect world -- the tc_link_layer (and the associated
>tc_ratespec.linklayer and  tc_sizespec.linklayer) should be removed
>from the kernel,
>but I'm not sure of the compatibility implications of this ...
>Do you have any suggestions?
>
>>
>> Also, please make you email working. Says to me:
>>
>> ** Address not found **
>>
>> Your message wasn't delivered to McCabe@rockwellcollins.com because the address couldn't be found. Check for typos or unnecessary spaces and try again.
>>
>> This is annoying.
>
>I think I fixed it -- was mis-configuration in my .gitconfig (sorry,
>I'm still new at this).
