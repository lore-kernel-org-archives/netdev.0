From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: bpf filter : support for vlan tag
Date: Fri, 19 Oct 2012 14:02:55 -0700
Message-ID: <CAOxq_8NyGqtWzM4xQVXkLDijJ1ijGc0txQkhHA6JC63pXXgyvw@mail.gmail.com>
References: <CAOxq_8MqMatY2+GA6+mHjj5V=Xe7Y8BmuX4r6cz5nChU5C1Vzw@mail.gmail.com>
	<1350369998.3954.563.camel@edumazet-glaptop>
	<CAD6jFUTn98+i_0eh6gc-CYgVXHNLbZdZmV6==mL+duFM-oNRmg@mail.gmail.com>
	<1350386917.3954.890.camel@edumazet-glaptop>
	<CAOxq_8NWMy2gL4QQv_e2hjHZZnFyFghmXzN5EnrXz3SRULxR6A@mail.gmail.com>
	<CAD6jFURcGt-xwE7WGXPvfGZ1JXAWC+sVNnN+gbpEyQSJYvxDnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Daniel Borkmann <danborkmann@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:44523 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754195Ab2JSVC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 17:02:56 -0400
Received: by mail-ia0-f174.google.com with SMTP id y32so637402iag.19
        for <netdev@vger.kernel.org>; Fri, 19 Oct 2012 14:02:55 -0700 (PDT)
In-Reply-To: <CAD6jFURcGt-xwE7WGXPvfGZ1JXAWC+sVNnN+gbpEyQSJYvxDnQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 19, 2012 at 1:53 PM, Daniel Borkmann
<danborkmann@iogearbox.net> wrote:
> On Fri, Oct 19, 2012 at 8:32 PM, Ani Sinha <ani@aristanetworks.com> wrote:
>> how about this?
>>
>> On Tue, Oct 16, 2012 at 4:28 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>
>>> @@ -341,6 +342,12 @@ load_b:
>>>                 case BPF_S_ANC_CPU:
>>>                         A = raw_smp_processor_id();
>>>                         continue;
>>> +               case BPF_S_ANC_VLAN_TAG:
>>> +                       A = vlan_tx_tag_get(skb);
>>> +                       continue;
>>> +               case BPF_S_ANC_VLAN_TAG_PRESENT:
>>> +                       A = !!vlan_tx_tag_present(skb);
>>> +                       continue;
>>>                 case BPF_S_ANC_NLATTR: {
>>>                         struct nlattr *nla;
>>
>>
>> +               case BPF_S_ANC_VLAN_TAG:
>> +                       if (!vlan_tx_tag_present(skb)) {
>> +                               return 0;
>> +                       }
>> +                       A = vlan_tx_tag_get(skb);
>> +                       continue;
>
> I didn't look into the code, but I assume that if no vlan is present,
> then vlan_tx_tag_get might return 0 anyway.

This might not be true all the time. So it's always safe to do this
check before returning the VLANID and throw some kind of error if the
vlan ID is not set.


 Also, your return is
> simply wrong, since then after this instruction you leave the *whole*
> BPF machine ignoring the rest of the filter program to process ...


I had done that because I can see in other parts of that state machine
that in error condition the code simply stops processing the packet. I
am not sure how else to handle the error case.

Ani
