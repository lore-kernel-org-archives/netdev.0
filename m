From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netfront: avoid packet loss when ethernet header crosses page boundary
Date: Mon, 29 Aug 2016 12:28:44 +0200
Message-ID: <87wpizamxv.fsf@vitty.brq.redhat.com>
References: <1471880577-21380-1-git-send-email-vkuznets@redhat.com>
        <57BB2E7B.5040303@citrix.com> <87twebb9of.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Juergen Gross <jgross@suse.com>,
        Patrick Talbert <ptalbert@redhat.com>,
        <linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
        Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87twebb9of.fsf@vitty.brq.redhat.com> (Vitaly Kuznetsov's message
        of "Tue, 23 Aug 2016 20:51:44 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vitaly Kuznetsov <vkuznets@redhat.com> writes:

> David Vrabel <david.vrabel@citrix.com> writes:
>
>> On 22/08/16 16:42, Vitaly Kuznetsov wrote:
>>> 
>>> I see two ways to fix the issue:
>>> - Change the 'wire' protocol between netfront and netback to start keeping
>>>   the original SKB structure. We'll have to add a flag indicating the fact
>>>   that the particular request is a part of the original linear part and not
>>>   a frag. We'll need to know the length of the linear part to pre-allocate
>>>   memory.
>>
>> I don't think there needs to be a protocol change.  I think the check in
>> netback is bogus -- it's the total packet length that must be >
>> HLEN_ETH.  The upper layers will pull any headers from the frags as
>> needed
>
> I'm afraid this is not always true, just removing the check leads us to
> the following:
>
> [  495.442186] kernel BUG at ./include/linux/skbuff.h:1927! 
> [  495.468789] invalid opcode: 0000 [#1] SMP 

What I wanted to say here is that this test makes me think the
description of the patch I suggested is correct: an SKB can't have its
linear part shorter than ETH_HLEN as the header is being pointed directly,
upper network layers don't assemble it from frags, the check in netback
is valid.

So, how can we proceed here?

-- 
  Vitaly
