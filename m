From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net-next v3 8/8] geneve: break dependency to network drivers
Date: Fri, 8 Jan 2016 16:38:29 -0800
Message-ID: <CAEh+42j0Cse6dPNU9axF=7kRkktHCsUzbGVj37C4hi6YL2jUDQ@mail.gmail.com>
References: <1452123571-19140-1-git-send-email-hannes@stressinduktion.org>
 <1452123571-19140-9-git-send-email-hannes@stressinduktion.org>
 <CAEh+42h79Sxc4JwzH_zMm+MZ-CmQWGdX1Qiz7epJmj2nCiAAVQ@mail.gmail.com>
 <5690204B.7000004@stressinduktion.org> <CAEh+42izmdn5hHBxQWfSQEduWE2OeY0puM-5DEU-iHTWYXdobQ@mail.gmail.com>
 <5690278E.5090903@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:53534 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750835AbcAIAiq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 19:38:46 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 30737201ED
	for <netdev@vger.kernel.org>; Sat,  9 Jan 2016 00:38:45 +0000 (UTC)
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 48564201E4
	for <netdev@vger.kernel.org>; Sat,  9 Jan 2016 00:38:44 +0000 (UTC)
Received: by mail-qg0-f48.google.com with SMTP id b35so235455962qge.0
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 16:38:44 -0800 (PST)
In-Reply-To: <5690278E.5090903@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 8, 2016 at 1:18 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On 08.01.2016 22:12, Jesse Gross wrote:
>>
>> On Fri, Jan 8, 2016 at 12:47 PM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>>>
>>> On 07.01.2016 01:18, Jesse Gross wrote:
>>>>
>>>>
>>>> I think we should merge vxlan_get_rx_port() and geneve_get_rx_port()
>>>> into a single generic function. For drivers that support both, they
>>>> now have two calls to get notified for all offloaded ports. This
>>>> actually can cause problems related to duplicates, similar to what you
>>>> feared before.
>>>
>>>
>>>
>>> Checking out the ndo_add_vxlan_port callbacks, we cannot change how we
>>> refresh the ports unfortunately. For some drivers it might be easy to
>>> update, some look a little bit more complicated.
>>>
>>> I guess we should try to keep more complexity in the core and make sure
>>> we
>>> only call those functions if necessary for the particular type of offload
>>> than to replicate the logic in each driver.
>>>
>>> If you agree I prepare this series with the changes to have separate
>>> callbacks, address your other feedback and send it out.
>>
>>
>> I'm not sure that I totally understand, do you have an example of a
>> problematic driver?
>
>
> bnx2x e.g. does refcounting on the port. So when it will implement geneve
> offloading, it will refcount the vxlan port multiple times with the current
> schema. Currently this is safe, as bnx2x doesn't care about geneve and thus
> no further callbacks will happen. But I fear drivers being broken as soon as
> they implement geneve additionally with the current schema.

OK, I understand what you mean now. I guess having a combined callback
function still seems cleaner to me overall and the exceptions are
relatively few, so I would probably continue to lean towards this
direction. In any case, I think it's hard for the core network stack
to completely handle the complexity as drivers can have various
restrictions on the number of ports, etc. that they support for
offloading.
