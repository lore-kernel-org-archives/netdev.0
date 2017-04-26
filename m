From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net 3/3] team: use a larger struct for mac address
Date: Wed, 26 Apr 2017 10:28:12 -0700
Message-ID: <CAM_iQpUGSy7My+hLXhsreq-8wPEdAKzNkQRzu-aiP5nkk+wSdw@mail.gmail.com>
References: <1493183003-884-1-git-send-email-xiyou.wangcong@gmail.com>
 <1493183003-884-4-git-send-email-xiyou.wangcong@gmail.com>
 <20170426054033.GA1867@nanopsycho.orion> <7103fb6b-2483-37c0-48e5-19aa9fd4f386@redhat.com>
 <CAM_iQpVXBuXNfVM_h894HEF_9hv2rWgDJcMbvEJG25xfm7DGUA@mail.gmail.com> <3f48c69c-3ff4-f895-3c0f-2e8c9c5f063a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33535 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753438AbdDZR2d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 13:28:33 -0400
Received: by mail-wm0-f66.google.com with SMTP id y10so2984128wmh.0
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 10:28:33 -0700 (PDT)
In-Reply-To: <3f48c69c-3ff4-f895-3c0f-2e8c9c5f063a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 9:46 AM, Jarod Wilson <jarod@redhat.com> wrote:
> On 2017-04-26 12:11 PM, Cong Wang wrote:
>>
>> On Wed, Apr 26, 2017 at 8:55 AM, Jarod Wilson <jarod@redhat.com> wrote:
>>>
>>>
>>> We already have struct sockaddr_storage that could be used throughout
>>> this
>>> set as well. We just converted a few pieces of the bonding driver over to
>>> using it for better support of ipoib bonds, via commit
>>> faeeb317a5615076dff1ff44b51e862e6064dbd0. Might be better to just use
>>> that
>>> in both bonding and team, rather than having different per-driver
>>> structs,
>>> or Yet Another Address Storage implementation.
>>
>>
>> Technically, struct sockaddr_storage is not enough either, given the
>> max is MAX_ADDR_LEN. This is why I gave up on sockaddr_storage.
>
>
> Wait, what? Am I missing something? MAX_ADDR_LEN is 32, and sockaddr_storage
> is a #define for __kernel_sockaddr_storage, which has it's __data member
> defined as being of size 128 - sizeof(unsigned short).

My bad, I thought it is same with sizeof(in6addr) without looking into it.
The question is, why do we waste 126 - 32 = 94 bytes on stack to just
use struct sockaddr_storage?

I totally understand we want a unified struct, but we already redefine
it in multiple places in tree...
