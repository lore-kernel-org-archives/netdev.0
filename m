From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH nf-next v2 1/2] netfilter: Fix potential null pointer dereference
Date: Wed, 28 Sep 2016 15:56:40 +0800
Message-ID: <CA+6hz4o4jA4quVRWdG8Tcb7miEQxBpK8bvOcsLW2LX74jYvSQg@mail.gmail.com>
References: <1474983515-4115-1-git-send-email-aconole@bytheb.org>
 <1474983515-4115-2-git-send-email-aconole@bytheb.org> <CA+6hz4q_Fjc7mVZq7RG+RnioXFnD0w8Ows0AqwEy-5CJ7zg0yQ@mail.gmail.com>
 <CAML_gOeTZhaWXffe0UqXRP_e=-+1vCs_z9ynrG7XJeUnmOs-6A@mail.gmail.com> <CAML_gOeqjO--cPu=vt+ed14NqXP1uU41J0RDg5Up7xM79SCWjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Aaron Conole <aconole@bytheb.org>,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: Liping Zhang <zlpnobody@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f66.google.com ([209.85.213.66]:36571 "EHLO
        mail-vk0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751438AbcI1H4n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 03:56:43 -0400
In-Reply-To: <CAML_gOeqjO--cPu=vt+ed14NqXP1uU41J0RDg5Up7xM79SCWjQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Liping,

On Wed, Sep 28, 2016 at 11:13 AM, Liping Zhang <zlpnobody@gmail.com> wrote:
> 2016-09-28 11:08 GMT+08:00 Liping Zhang <zlpnobody@gmail.com>:
>> Hi Feng,
>>
>> 2016-09-28 9:23 GMT+08:00 Feng Gao <gfree.wind@gmail.com>:
>>> Hi Aaraon,
>>>
>>> On Tue, Sep 27, 2016 at 9:38 PM, Aaron Conole <aconole@bytheb.org> wrote:
>>>> It's possible for nf_hook_entry_head to return NULL if two
>>>> nf_unregister_net_hook calls happen simultaneously with a single hook
>>>
>>> The critical region of nf_unregister_net_hook is protected by &nf_hook_mutex.
>>> When it would be called simultaneously?
>>
>> This is unrelated to race condition.
>>
>> Suppose that only the last nf_hook_entry exist, and two callers want to do
>> un-register work.
>>
>> The first one will remove it successfully, after the end of the work, the
>> second one will enter the critical section, but it will see the NULL pointer.
>> Because the last nf_hook_entry was already removed by the first one.
>>
>>>
>>> Regards
>>> Feng
>>>
>>>> entry in the list.  This fix ensures that no null pointer dereference
>>>> could occur when such a race happens.
>>>>
>>>> Signed-off-by: Aaron Conole <aconole@bytheb.org>
>
> I read the commit log again, I think the description here is a
> little confusing indeed.

Yes. I doesn't check if the list head always exists, just learn the
patch from commit log.
It confuses me indeed.

Regards
Feng
