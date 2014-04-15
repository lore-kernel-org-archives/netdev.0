From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] filter: added BPF random opcode
Date: Tue, 15 Apr 2014 18:44:29 +0200
Message-ID: <534D61ED.9070203@redhat.com>
References: <1397516569-31033-1-git-send-email-chema@google.com> <534CDE99.6090407@redhat.com> <CA+ZOOTMmRiACgBtMSWm-Barr_MZS446Z5M2Z6B+HmZYwqcvh6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	ast@plumgrid.com
To: Chema Gonzalez <chema@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24482 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752211AbaDOQom (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2014 12:44:42 -0400
In-Reply-To: <CA+ZOOTMmRiACgBtMSWm-Barr_MZS446Z5M2Z6B+HmZYwqcvh6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/15/2014 06:30 PM, Chema Gonzalez wrote:
> On Tue, Apr 15, 2014 at 12:24 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> Hi Chema,
>>
>> [cc'ing Alexei as well]
>>
>> note, net-next is still closed, so you might need to resend this later
>> on again when it opens up.
> I will. Thanks!

Great, thanks.

>> On 04/15/2014 01:02 AM, Chema Gonzalez wrote:
>>> diff --git a/tools/net/bpf_exp.l b/tools/net/bpf_exp.l
>>> index bf7be77..804256f 100644
>>> --- a/tools/net/bpf_exp.l
>>> +++ b/tools/net/bpf_exp.l
>>> @@ -92,6 +92,7 @@ extern void yyerror(const char *str);
>>>    "#"?("cpu")   { return K_CPU; }
>>>    "#"?("vlan_tci") { return K_VLANT; }
>>>    "#"?("vlan_pr")       { return K_VLANP; }
>>> +"#"?("random") { return K_RAND; }
>>
>>
>> Thanks for also updating bpf_asm ! :)
> bpf_asm was key in ensuring this worked. In fact, we should modify the
> Makefile so that it relies on the local filter.h before the
> /usr/include/ one (my Ubuntu Precise /usr/include/linux/filter.h does
> not define BPF_MOD, BPF_XOR, SKF_AD_VLAN_TAG, SKF_AD_VLAN_TAG_PRESENT,
> or SKF_AD_PAY_OFFSET).

Good point, feel free to send a patch. :)

>> I think using just "rnd" is cleaner here.
> I think using always random (in fact I may s/K_RAND/K_RANDOM/g) allows
> easier grepping.

I know it's just nitpicking, but I'd be happier if that would
either be rnd or rand in bpf_asm.

>>> diff --git a/tools/net/icmp_random.bpf b/tools/net/icmp_random.bpf
>>> new file mode 100644
>>> index 0000000..b9adcbf
>>> --- /dev/null
>>> +++ b/tools/net/icmp_random.bpf
>>> @@ -0,0 +1,12 @@
>>> +# icmp random packet sampling, 1 in 4
>>> +ldh [12]
>>> +jne #0x800, drop
>>> +ldb [23]
>>> +jneq #1, drop
>>> +# get a random uint32 number
>>> +ld random
>>> +mod #4
>>> +jneq #1, drop
>>> +ret #-1
>>> +drop: ret #0
>>> +
>>>
>>
>> This example should rather go into Documentation/networking/filter.txt's
>> example section, rather than tools/net/ .
> I'll add it there.

Ok, thanks.

> Now, I'd like to add a new directory for BPF programs (tools/net/bpf/
> ?). It allows playing with bpf_asm.

For 'playing', I'd rather be happy to add that to the documentation file
in Documentation/networking/filter.txt where we have other examples, or
alternatively, if there is really no other way around, a new folder inside
of Documentation/networking/ .
