From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH 1/2] sctp: SCTP_SOCKOPT_PEELOFF return socket pointer
 for kernel users
Date: Mon, 13 Jul 2015 10:19:25 -0300
Message-ID: <55A3BADD.9040303@gmail.com>
References: <4dfd0ee7ac0aac0791812217e990e2ae7ff86955.1434645734.git.marcelo.leitner@gmail.com> <20150710.182114.1532697560595947999.davem@davemloft.net> <20150713103911.GA9631@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com
To: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:34937 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614AbbGMNTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 09:19:31 -0400
Received: by qkbp125 with SMTP id p125so253483161qkb.2
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 06:19:30 -0700 (PDT)
In-Reply-To: <20150713103911.GA9631@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-07-2015 07:39, Neil Horman wrote:
> On Fri, Jul 10, 2015 at 06:21:14PM -0700, David Miller wrote:
>> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
>> Date: Thu,  9 Jul 2015 11:15:19 -0300
>>
>>> SCTP has this operation to peel off associations from a given socket and
>>> create a new socket using this association. We currently have two ways
>>> to use this operation:
>>> - via getsockopt(), on which it will also create and return a file
>>>    descriptor for this new socket
>>> - via sctp_do_peeloff(), which is for kernel only
>>>
>>> The caveat with using sctp_do_peeloff() directly is that it creates a
>>> dependency to SCTP module, while all other operations are handled via
>>> kernel_{socket,sendmsg,getsockopt...}() interface. This causes the
>>> kernel to load SCTP module even when it's not directly used
>>>
>>> This patch then updates SCTP_SOCKOPT_PEELOFF so that for kernel users of
>>> this protocol it will not allocate a file descriptor but instead just
>>> return the socket pointer directly.
>>>
>>> If called by an user application it will work as before.
>>>
>>> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
>>
>> I do not like this at all.
>>
>> Socket option implementations should not change their behavior or what
>> datastructures they consume or return just because the socket happens
>> to be a kernel socket.
>>
> But in this case its necessecary, as the kernel here can't allocate an fd, due
> to serious leakage (see commit 2f2d76cc3e938389feee671b46252dde6880b3b7).
> Initially Marcelo had created duplicate code paths, one to return an fd, one to
> return a file struct.  If you would rather go in that direction, I'm sure he can
> propose it again, but that seems less correct to me than this solution.

Yes.

dlm is the only user of this option within kernel today and it causes 
serious problems, as Neil just referenced. Another good result of this 
implementation is that we are preventing such leakage from happening 
again in the future.

>> I'm not applying this series, sorry.
>>
>> Also, your patch series lacked an intial "PATCH 0/N" posting, so you
>> could at least spend the time to discuss this patch series at a high
>> level and explain your overall motivations.
>>
> That was in the initial posting.  It should have been reposted, but if you're
> interested:
> http://marc.info/?l=linux-sctp&m=143449456219518&w=2

My bad. Won't happen again.

Thanks,
Marcelo
