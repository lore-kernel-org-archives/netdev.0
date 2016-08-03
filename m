From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: net: vrf: Handle ipv6 multicast and link-local addresses
Date: Wed, 3 Aug 2016 14:36:34 -0600
Message-ID: <b23bf44d-1334-cbbc-6fa3-e1705a8e06f0@cumulusnetworks.com>
References: <20160727215224.EB4E26611D4@gitolite.kernel.org>
 <CAMuHMdU6zpowkWgUW0+8Fhx7BmwTn=FvVBoTKXUgNzLeBpFrHg@mail.gmail.com>
 <1d0eb1d8-708f-2238-37c9-b75004804065@cumulusnetworks.com>
 <CAMuHMdWGX3owP=xr-hhr6gE9PFRFc55Rzsc1M1JVoFLHdmuUYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdWGX3owP=xr-hhr6gE9PFRFc55Rzsc1M1JVoFLHdmuUYQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/3/16 2:27 PM, Geert Uytterhoeven wrote:
> On Wed, Aug 3, 2016 at 10:11 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>> On 8/3/16 1:57 PM, Geert Uytterhoeven wrote:
>>>> +static void vrf_ip6_input_dst(struct sk_buff *skb, struct net_device *vrf_dev,
>>>>> +                             int ifindex)
>>>>> +{
>>>>> +       const struct ipv6hdr *iph = ipv6_hdr(skb);
>>>>> +       struct flowi6 fl6 = {
>>>>> +               .daddr          = iph->daddr,
>>>>> +               .saddr          = iph->saddr,
>>>>> +               .flowlabel      = ip6_flowinfo(iph),
>>> The above assignment causes the following compiler warning with
>>> m68k-linux-gnu-gcc-4.1:
>>>
>>>     drivers/net/vrf.c: In function ‘vrf_ip6_input_dst’:
>>>     drivers/net/vrf.c:870: warning: initialized field with
>>> side-effects overwritten
>>>     drivers/net/vrf.c:870: warning: (near initialization for ‘fl6’)
>>>
>>> Unfortunately I have no idea what it means, nor do I see what's wrong
>>> with the code.
>>
>> no idea. Fields are initialized once and left and right data types are the same.
>>
>> Can you remove one line at a time? Line 870 is ".flowi6_proto   = iph->nexthdr," but all of the flowi6 macros are unique references to unique fields in flowi_common. The flowlabel line you point out is a unique field as well.
> 
> The only thing that seems to matter is assigning the result of the call to
> ip6_flowinfo() to .flowlabel. Assigning a constant makes the warning go away.

No complaints for the same initialization style at line 151?
