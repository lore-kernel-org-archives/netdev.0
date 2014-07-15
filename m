From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net-next 2/2] bonding: make hard-coded defines
 configurable at build
Date: Tue, 15 Jul 2014 19:11:39 +0200
Message-ID: <20140715171139.GD5225@mikrodark.usersys.redhat.com>
References: <1405419341-31510-1-git-send-email-vfalico@gmail.com>
 <1405419341-31510-3-git-send-email-vfalico@gmail.com>
 <CAADnVQJCNJVTBFkinNzo=1mSWEBhif3dOVnVvuievJxijtNb7w@mail.gmail.com>
 <20140715161802.GC5225@mikrodark.usersys.redhat.com>
 <CAADnVQJaUQsDF1--4ffnCUz=1Tw1Ox=kgUw3h1L1EnrDs0WQfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f182.google.com ([74.125.82.182]:51436 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755534AbaGOROh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 13:14:37 -0400
Received: by mail-we0-f182.google.com with SMTP id q59so5969349wes.13
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 10:14:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAADnVQJaUQsDF1--4ffnCUz=1Tw1Ox=kgUw3h1L1EnrDs0WQfw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 09:45:36AM -0700, Alexei Starovoitov wrote:
>On Tue, Jul 15, 2014 at 9:18 AM, Veaceslav Falico <vfalico@gmail.com> wrote:
>> On Tue, Jul 15, 2014 at 08:48:01AM -0700, Alexei Starovoitov wrote:
>>>
>>> On Tue, Jul 15, 2014 at 3:15 AM, Veaceslav Falico <vfalico@gmail.com>
>>> wrote:
>>>>
>>>> +
>>>> +config BOND_MAX_VLAN_ENCAP
>>>> +       int "Maximum number of stacked vlans on top of bonding"
>>>> +       default "2"
>>>> +
>>>
>>> I don't think we should allow changing these defaults so easily.
>>> Not a single HW supports 3 vlan tags. There is no standard for it either.
>>> Why you would ever change this?
>>
>> There have been discussions about vlan nestings for bonding, and the
>> outcome was that more than 2 are possible. Also, iirc, no standard limits
>> it to only 2.
>
>standard doesn't say that the maximum is 2, but it doesn't specify what
>should be done in such case, so all vlan-aware switches that I know will
>be just dropping packets with 3 vlans.

There might be switches that support it/don't really care, there are
bridges (including soft ones) etc. that all can make use of it.

Given that it's a build-time configuration option that affects a small part
of arp monitoring, which is a small part of bonding module, which is ... -
I don't understand why it can't be configured.

>Therefore for bond driver there is no reason to accept such packets
>in the first place from user space, since they won't go too far in the network.
>
>> These defaults are scalable by their nature, and there are people
>> maintaining their own patches to change them. So making them available to
>> be configured at compile time is a good thing to do, I think.
>
>people keep a patch to support 3 vlans? what's the use case?

I guess it has something to do with virtualization, including nested one.

But, again, does this matter? I don't see how it can give us something bad.
It's a configuration option with a default value that suits most users, and
that might be configured for some advanced/weird use-cases.
