From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next V6 02/14] bridge: Add vlan filtering infrastructure
Date: Tue, 22 Jan 2013 11:27:01 -0500
Message-ID: <50FEBDD5.5030205@redhat.com>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com> <1358360289-23249-3-git-send-email-vyasevic@redhat.com> <CAHXqBFKg6Vp5=dprDYKON2LmshhX+nSPF7KRHiQmOS68PrQq-A@mail.gmail.com> <50FC307A.5090003@redhat.com> <20130120113825.759b4a58@nehalam.linuxnetplumber.net> <50FC9F03.5000102@redhat.com> <20130121134534.78032a54.shmulik.ladkani@gmail.com> <50FEA2CF.4060406@redhat.com> <20130122175524.033c6f7f.shmulik.ladkani@gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com,
	mst@redhat.com
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19826 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753383Ab3AVQ1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 11:27:07 -0500
In-Reply-To: <20130122175524.033c6f7f.shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2013 10:55 AM, Shmulik Ladkani wrote:
> Thanks Vlad,
>
> On Tue, 22 Jan 2013 09:31:43 -0500 Vlad Yasevich <vyasevic@redhat.com> wrote:
>>> I guess this might simplify the data structures involved, avoiding the
>>> refcounts, etc...
>>>
>>> The penaties are:
>>>    - memory
>>>    - aesthetics (?)
>>>    - inefficient if query is "give me the entire list of VLANs port P is
>>>      member of". But do we have such a query in bridge's code?
>>
>> Yes.  When a mac address is added to a port without an explicit vlan tag
>> we try to add it for every vlan available on the port.
>
> I see.
> Can't this be bypassed by adding a _single_ FDB entry whose VID value
> denotes "member of ANY vlan" (value outside the valid 0-4095 range)?
>
>> Also, in the API, the user may request vlans configured on a port.
>
> Personally I'd pay the penalty implementing this specific user request
> in an inefficeint way, to acheive overall simplicity in core bridge
> code.
> But that's just my humble opinion, maybe others might spot drawbacks
> taking this approach.
>
> BTW, went through the ML, couldn't find the reason why dropped the
> per-port vlan bitmap and replaced with a vlan list (after your RFC v2
> patches). Care to explain what was your motivation?

I wanted to reduce the memory footprint and make it a bit more 
extensible so if priority was ever added, it would be very simple to do.
I also had to play some ugly memory barrier games to make it less racy.
I thought that the list/hash code was cleaner.

-vlad

>
> Regards,
> Shmulik
>
