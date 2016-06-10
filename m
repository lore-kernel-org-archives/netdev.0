From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] net, cls: allow for deleting all filters for
 given parent
Date: Fri, 10 Jun 2016 07:49:41 -0400
Message-ID: <575AA955.6030809@mojatatu.com>
References: <cd8455dfef0cccec5ef0a1ca2d1f678e9397d66e.1465056745.git.daniel@iogearbox.net>
 <CAM_iQpWDc1JAa9MhcSAOdJVVRoG52Z+p47CD-rd81LzN28zk1A@mail.gmail.com>
 <5755CE3A.7050002@iogearbox.net>
 <CAM_iQpXJAa5B=4ez9z+-Q66rFj+EUTGwrYWMhYoCK=3rp65gYw@mail.gmail.com>
 <57588E66.8070509@iogearbox.net>
 <CAM_iQpVga4J92BJr6_zxMwVg4M=VBeqveiTiqHG+chnk3ZD2TA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:34961 "EHLO
	mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753110AbcFJLt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 07:49:56 -0400
Received: by mail-it0-f47.google.com with SMTP id z189so179121103itg.0
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 04:49:56 -0700 (PDT)
In-Reply-To: <CAM_iQpVga4J92BJr6_zxMwVg4M=VBeqveiTiqHG+chnk3ZD2TA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-09 06:54 PM, Cong Wang wrote:
> On Wed, Jun 8, 2016 at 2:30 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> On 06/06/2016 09:52 PM, Cong Wang wrote:
>>>
>>> On Mon, Jun 6, 2016 at 12:25 PM, Daniel Borkmann <daniel@iogearbox.net>
>>> wrote:
>>

>> I've been playing around with both options and am actually currently
>> leaning towards the tfilter_notify() for each proto for the reason
>> that user space tc monitors can simply stay as is. F.e., if someone
>> keeps an older libnl binary that wouldn't understand such a wildcard
>> message, then elements in libnl cache won't receive updates since the
>> meta data won't match on them (average case, there probably are only
>> one up to a handful of classifiers per parent) ... hm, different topic
>> but still wondering whether libnl relying on such messages is a good
>> idea in general since under stress tfilter_notify() can also fail and
>> user space won't get the updates (except for queries with RTM_GETTFILTER).
>
> Don't worry about any failure in tfilter_notify(), we call it in
> non-wildcard removal too. Your current patch looks good to me.
>
> Thanks!
>

Daniel, I acked this already (sorry I missed the event notification
bits).

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
