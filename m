From: Rao Shoaib <rao.shoaib@oracle.com>
Subject: Re: [PATCH v1 net] TCP_USER_TIMEOUT and tcp_keepalive should conform
 to RFC5482
Date: Wed, 9 Aug 2017 17:31:15 -0700
Message-ID: <f5ca5e4b-d974-8389-4414-c3ba9c81f59f@oracle.com>
References: <20170807181614.GA16700@caduceus5>
 <CAK6E8=ehu5uK6bsprzAQc-Nu6WS2YQEcktD0H2RrjgPpS47-Yg@mail.gmail.com>
 <CAPshTCgaYVPEbZxDr9sUz7OFibweQn6fwRtP66cgw5eNrHUOWA@mail.gmail.com>
 <CABGNeczGSsL6xj-SkXQYTWXXe+mJoyhvrQxuLkiO27pW0y8MtA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        netdev <netdev@vger.kernel.org>
To: Joe Smith <codesoldier1@gmail.com>, Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42150 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751890AbdHJAbo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 20:31:44 -0400
In-Reply-To: <CABGNeczGSsL6xj-SkXQYTWXXe+mJoyhvrQxuLkiO27pW0y8MtA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/09/2017 05:20 PM, Joe Smith wrote:
> On Wed, Aug 9, 2017 at 4:52 PM, Jerry Chu <hkchu@google.com> wrote:
>> [try to recover from long lost memory]
>>
>> On Tue, Aug 8, 2017 at 10:25 AM, Yuchung Cheng <ycheng@google.com> wrote:
>>> On Mon, Aug 7, 2017 at 11:16 AM, Rao Shoaib <rao.shoaib@oracle.com> wrote:
>>>> Change from version 0: Rationale behind the change:
>>>>
>>>> The man page for tcp(7) states
>>>>
>>>> when used with the TCP keepalive (SO_KEEPALIVE) option, TCP_USER_TIMEOUT will
>>>> override keepalive to  determine  when to close a connection due to keepalive
>>>> failure.
>>>>
>>>> This is ambigious at best. user expectation is most likely that the connection
>>>> will be reset after TCP_USER_TIMEOUT milliseconds of inactivity.
>>> ccing the original author Jerry Chu who can tell more.
>>>
>> There was a reason for the above otherwise I wouldn't have explicitly
>> spelled it out in
>> my commit msg. But unfortunately it was seven years ago and I can't
>> remember why.
>> It could range from micro-optimization (saving a syscall() because
>> this facility was
>> used by servers handling millions of Android clients) to something more critical
>> but I can't remember.
> The issue is that the man page is ambiguous and does not conform to
> any standard.
> Whether  RFC 5482 is in little use or not that was cited as the basis
> of this change and
> I want to change the behavior to conform to it as users are confused.
>
> I doubt that saving a syscall is of any benefit when the connection
> has been idle for 2hrs. If anything the user expects the keep alive
> probes to start after TCP_USER_TIMEOUT of inactivity. In which case
> keep alive should be adjusted.
>
>>>> The code however waits for the keepalive to kick-in (default 2hrs) and than
>>>> after one failure resets the conenction.
>>>>
>>>> What is the rationale for that ? The same effect can be obtained by simply
>>>> changing the value of tcp_keep_alive_probes.
>>>>
>>>> Since the TCP_USER_TIMEOUT option was added based on RFC 5482 we need to follow
>>>> the RFC. Which states
>> Well the patch has little to do with RFC5482 other than borrowing the name, and
>> also conveniently providing a mechanism for RFC5482 apps to program the local
>> timeout value. As far as I knew back when I worked on the patch, RFC5482 was
>> under little use (told directly by Lars).
>>
>> Your proposed change may not be unreasonable but my fear is it may
>> cause breakage
>> on apps that depend on "TCP_USER_TIMEOUT will overtake keepalive to determine
>> when to close a connection due to keepalive failure". What is your
>> case for "RFC5482
>> compliance" after all? I know the TCP_USER_TIMEOUT option has been very popular
>> among apps since its inception.
> The only use of TCP_USER_TIMEOUT has been for flushing unacknowledged
> data (evident from all the fixes). That behavior is not being touched.
>
> Making Linux conform to standards and behavior that is logical seems
> like a good enough reason. Mixing keep alive and TCP_USER_TIMEOUT does
> not make any sense. I doubt very much if this change will break
> anything but if it does than we need to see why that is needed and
> implement a proper fix and document it.
>
>
The behavior for the main use case has been previously changed as part 
of bug fixes. This is a very low risk change and makes the code logical 
and clean.

Shoaib
