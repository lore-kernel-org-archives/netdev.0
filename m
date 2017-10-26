From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCHv5 iproute2 net-next 2/2] lib/libnetlink: re malloc buff if
 size is not enough
Date: Thu, 26 Oct 2017 09:42:46 -0600
Message-ID: <4dd9b1a2-878d-dfe0-f9b7-f000fbde3c6c@gmail.com>
References: <1508982107-28474-1-git-send-email-liuhangbin@gmail.com>
 <1508982107-28474-2-git-send-email-liuhangbin@gmail.com>
 <10ef7665-b47a-881a-ab00-1e2c6c224d0b@gmail.com>
 <20171026122442.7e2ac2d0@shemminger-XPS-13-9360>
 <25f0ec07-e36a-510c-c01f-56df8a843f80@gmail.com>
 <20171026153340.GX32305@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org,
        Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:53507 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932255AbdJZPmp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:42:45 -0400
Received: by mail-pf0-f194.google.com with SMTP id t188so2777998pfd.10
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 08:42:45 -0700 (PDT)
In-Reply-To: <20171026153340.GX32305@orbyte.nwl.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/17 9:33 AM, Phil Sutter wrote:
> On Thu, Oct 26, 2017 at 09:28:00AM -0600, David Ahern wrote:
>> On 10/26/17 4:24 AM, Stephen Hemminger wrote:
>>>>
>>>> The kernel needs a flag that says "give me the message of the buffer is
>>>> large enough; if not just PEEK and tell me the length." That would avoid
>>>> the double call in most cases.
>>>
>>> Actually this has little impact because old code was doing implicit zero
>>> of whole buffer, new code does not.
>>>
>>
>> The patch calls recvmsg twice; libnl does the same thing. It would be
>> better performance wise to have a flag that allows retrieval of the
>> message if the supplied buffer is large enough and PEEK semantics if
>> not. It was really a comment on how we could do better with proper
>> kernel support.
> 
> Doesn't MSG_TRUNC without MSG_PEEK do just that?

MSG_TRUNC returns the actual message length if it is greater than the
buffer. The message was dequeued and what could be copied into the
supplied buffer is copied, but that means the returned message is truncated.
