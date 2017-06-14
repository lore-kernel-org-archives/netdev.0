From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Receiving raw packets (incl. VLAN tags) on raw sockets
Date: Wed, 14 Jun 2017 11:54:25 -0500
Message-ID: <87o9tq7bni.fsf@xmission.com>
References: <e06dbb47-2d1c-03ca-4cd7-cc958b6a939e@gmail.com>
        <877f0eaax8.fsf@xmission.com>
        <8e65d057-a39c-6b83-b650-922ba9e86051@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, aeppert@gmail.com
To: Jan =?utf-8?Q?Grash=C3=B6fer?= <jan.grashoefer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:53230 "EHLO
        out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751980AbdFNRBW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 13:01:22 -0400
In-Reply-To: <8e65d057-a39c-6b83-b650-922ba9e86051@gmail.com> ("Jan
        \=\?utf-8\?Q\?Grash\=C3\=B6fer\=22's\?\= message of "Wed, 14 Jun 2017 18:03:27
 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Grashöfer <jan.grashoefer@gmail.com> writes:

> On 14/06/17 16:41, Eric W. Biederman wrote:
>> That does not work.  That is is just the software fallback for when
>> the device driver does not have a special case the processing
>> vlan tagged packets.
>>
>> There was a major inconsistency that for a long time the hardware
>> network drivers were stripping tags and the software ones were not.
>>
>> The code you are playing with is the fix for the rare slow path
>> that does not happen to strip the tags.  Disabling the rare slow path
>> might temporarily solve your symptoms but it will be much more painful
>> when you are entrenched in your ways and discover that high performance
>> hardware behaves differently than your software device.
>
> Thanks for your reply! Actually, I was referring to COTS hardware that
> incorporates offloading features. But, when it comes to (security)
> monitoring, offloading is usually disabled [1,2] to process the
> packets as seen on the wire. Thus the "slow path" would be the default
> path for most monitoring applications. That is, what makes this
> situation kind of weird. After turning off the NIC's VLAN offloading,
> it took me some time to realize that now the kernel strips off VLAN
> tags. If someone decides that VLAN offloading is not needed, I think
> the kernel should not enforce it.

In practice it is too too complicated to support both so we choose the
mode where vlan tags are always stripped.

I can imagine a tweak to pf_packet where it readds the vlan tag before
it gets to user space.  I can not image changing how we treat the vlan
tags internally to the kernel.

There were nasty kernel bugs before: 
bcc6d4790361 ("net: vlan: make non-hw-accel rx path similar to hw-accel")

I don't even want to contemplate opening that can of worms again.

Eric
