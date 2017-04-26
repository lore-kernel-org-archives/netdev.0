From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [Patch net 3/3] team: use a larger struct for mac address
Date: Wed, 26 Apr 2017 12:46:31 -0400
Message-ID: <3f48c69c-3ff4-f895-3c0f-2e8c9c5f063a@redhat.com>
References: <1493183003-884-1-git-send-email-xiyou.wangcong@gmail.com>
 <1493183003-884-4-git-send-email-xiyou.wangcong@gmail.com>
 <20170426054033.GA1867@nanopsycho.orion>
 <7103fb6b-2483-37c0-48e5-19aa9fd4f386@redhat.com>
 <CAM_iQpVXBuXNfVM_h894HEF_9hv2rWgDJcMbvEJG25xfm7DGUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45084 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751422AbdDZQqg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 12:46:36 -0400
In-Reply-To: <CAM_iQpVXBuXNfVM_h894HEF_9hv2rWgDJcMbvEJG25xfm7DGUA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-04-26 12:11 PM, Cong Wang wrote:
> On Wed, Apr 26, 2017 at 8:55 AM, Jarod Wilson <jarod@redhat.com> wrote:
>>
>> We already have struct sockaddr_storage that could be used throughout this
>> set as well. We just converted a few pieces of the bonding driver over to
>> using it for better support of ipoib bonds, via commit
>> faeeb317a5615076dff1ff44b51e862e6064dbd0. Might be better to just use that
>> in both bonding and team, rather than having different per-driver structs,
>> or Yet Another Address Storage implementation.
> 
> Technically, struct sockaddr_storage is not enough either, given the
> max is MAX_ADDR_LEN. This is why I gave up on sockaddr_storage.

Wait, what? Am I missing something? MAX_ADDR_LEN is 32, and 
sockaddr_storage is a #define for __kernel_sockaddr_storage, which has 
it's __data member defined as being of size 128 - sizeof(unsigned short).

-- 
Jarod Wilson
jarod@redhat.com
