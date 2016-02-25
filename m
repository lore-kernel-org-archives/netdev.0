From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 0/5] net_sched: Add support for IFE action
Date: Thu, 25 Feb 2016 07:35:51 -0500
Message-ID: <56CEF527.8040609@mojatatu.com>
References: <1456147304-13355-1-git-send-email-jhs@emojatatu.com>
 <56CB3B90.8030206@iogearbox.net> <56CC4BEA.70108@mojatatu.com>
 <56CC5CB6.1030807@iogearbox.net> <56CC6C75.1000903@mojatatu.com>
 <56CC7C20.3090302@iogearbox.net> <56CDA6E8.7010604@mojatatu.com>
 <56CDEF43.1010402@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34137 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279AbcBYMfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 07:35:54 -0500
Received: by mail-io0-f195.google.com with SMTP id l127so5479794iof.1
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 04:35:53 -0800 (PST)
In-Reply-To: <56CDEF43.1010402@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-24 12:58 PM, Daniel Borkmann wrote:
> On 02/24/2016 01:49 PM, Jamal Hadi Salim wrote:

>> Yes, a bit of that ++.
>> I am between two worlds: There are people who do user space packet
>> processing that claim they do so because they can quickly prototype
>> without compiling the kernel. My goal is to make it easy for people
>> adding new metadata without having to deal with kernel recompile.
>
> Seems like a case for cls_bpf? ;)
>

Yes, and ebpf is a good answer in a few such discussions these days.

>
> Ok, sure, given the assumption that this is only to be used in your own
> fully _controlled_ environment anyway.

It is - typically in the same rack; but could be across to another
room.


> But in that case, you don't even
> need to define any fixed IDs. Currently it seems like you could have
> different kernel versions with different IFE_META_MAX from the kernel
> headers and external modules define part of the ID space differently?
>

That is part of the problem.
Dynamic registration is not going to work well without some
human supervision. We are talking about large number of endpoints.
One machine cannot guarantee to be interested in the same metadata
as others and as you say they could be different kernels etc.
Even within same organization across different groups would require
some  coordination.

I will take that module param out and maybe describe a set of IDs that
are for "private use" and let whoever is deploying worry about
coordination. For the rest i will just have some LANANA or IANA
or kernel maintainance issues them. I should declare all the obvious
kernel ones.

cheers,
jamal
