From: Anand Gurram <anandarao.gurram@gmail.com>
Subject: Re: unregister_netdevice warnings when deleting netns
Date: Tue, 29 Sep 2015 11:59:57 +0530
Message-ID: <CAGGTERk3G=q09i0v2=Yo+2CQiwSn3qyhTq7ehw7A9ez0mqK=vQ@mail.gmail.com>
References: <CAGGTERmzF7oYABWUR+6UhddpOCtpkciVUMUOU-OcPkQvMznS8Q@mail.gmail.com>
	<alpine.LFD.2.11.1509282202270.7276@ja.home.ssi.bg>
	<8737xy5is2.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Julian Anastasov <ja@ssi.bg>, NETDEV <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:35017 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753740AbbI2G36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 02:29:58 -0400
Received: by ykdz138 with SMTP id z138so204135424ykd.2
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 23:29:57 -0700 (PDT)
In-Reply-To: <8737xy5is2.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>If the message just spits out a few times and then goes away it simply
>means that something is taking a while to cleanup and drop it's
>reference.

The message just spits out few times and then goes away, I am trying
to debug why cleanup is taking long,
and where it is still referenced. Any pointers in debugging such
issues will be of great help.

Best Regards,
Anand

On Tue, Sep 29, 2015 at 3:05 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Julian Anastasov <ja@ssi.bg> writes:
>
>>       Hello,
>>
>> On Mon, 28 Sep 2015, Anand Gurram wrote:
>>
>>> I am currently using kernel version 3.16.7 on a linux switch.
>>> While creating and destroying network namespaces I am observing below logs
>>> on the console
>>> "unregister_netdevice: waiting for lo to become free. Usage count = 1"
>>>
>>> Can you please suggest and provide instructions on how to debug this issue.
>>> If any fix already available can you please point me to the link.
>>
>>       There are two commits from Linux 4.2 that may help:
>>
>> commit e9e4dd3267d0 ("net: do not process device backlog during unregistration")
>> commit 2c17d27c36dc ("net: call rcu_read_lock early in process_backlog")
>>
>>       For now I see them only in 3.2.71+ and 3.12.48+.
>> I think, they will appear in other stable versions too...
>
> If that message repeats indefinitely it means there is a leaked
> reference to the network namespaces lo device.
>
> If the message just spits out a few times and then goes away it simply
> means that something is taking a while to cleanup and drop it's
> reference.
>
> This is slightly complicated by the fact that it is not uncommon when a
> network device goes away to redirect all references to itself to the lo
> device.
>
> Eric
