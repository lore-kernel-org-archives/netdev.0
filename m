From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v5] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 28 Sep 2016 06:43:01 -0400
Message-ID: <8293413c-a81d-f7ff-24f0-8f58ce877116@mojatatu.com>
References: <20160928090357.GT1876@uranus.lan>
 <caef7649-9d25-6429-eeab-96c027d6cbc2@mojatatu.com>
 <20160928101726.GU1876@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36794 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932226AbcI1KnF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 06:43:05 -0400
Received: by mail-io0-f193.google.com with SMTP id z135so2813274ioe.3
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 03:43:04 -0700 (PDT)
In-Reply-To: <20160928101726.GU1876@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-28 06:17 AM, Cyrill Gorcunov wrote:
> On Wed, Sep 28, 2016 at 06:08:00AM -0400, Jamal Hadi Salim wrote:
> ...
>>> @@ -38,7 +38,10 @@ struct inet_diag_req_v2 {
>>>  	__u8	sdiag_family;
>>>  	__u8	sdiag_protocol;
>>>  	__u8	idiag_ext;
>>> -	__u8	pad;
>>> +	union {
>>> +		__u8	pad;
>>> +		__u8	sdiag_raw_protocol;	/* SOCK_RAW only, @pad for others */
>>> +	};
>>
>>
>> Above looks funny. Why is it a union? pad is for exposing a byte-hole
>> for padding/alignment reasons and i doubt anybody is using it.
>
> Someone may have set it to zero explicitly on source level, and the
> compilation will fail on new kernel then. So no, keeping the name
> is reasonable.
>

I dont know how compilation will fail but you may be right with note:
that is not how pads have been used in the past. They are supposed to
cosmetic annotation which indicates "here's a hole; use it in the
future if you are looking to add something". And someone in the
future can claim them. I am not sure if MBZ philosophy applies.

>> Should you not just rename it?
>> Also I notice when things like __raw_v4_lookup() are claiming it is unsigned
>> short instead of a u8?
>
> The protocol is still up to 255 for a while, is it expected that IPPROTO_MAX
> will be increased in more-less near future? Of course I can drop the idea
> of using @pad here and switch to some extended reauest but prefer to stick
> with simplier solution. Hm?
>

Ok. If i understood correctly it was already unsigned short before your
patch -so i agree it doesnt matter. Maybe just put a comment to express
that if ever protocol goes above 255 it wont be sufficient.



cheers,
jamal

PS:- sorry for butting in the discussion - i blame it on coffee.
