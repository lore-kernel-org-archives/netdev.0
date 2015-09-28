From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: unregister_netdevice warnings when deleting netns
Date: Mon, 28 Sep 2015 16:35:41 -0500
Message-ID: <8737xy5is2.fsf@x220.int.ebiederm.org>
References: <CAGGTERmzF7oYABWUR+6UhddpOCtpkciVUMUOU-OcPkQvMznS8Q@mail.gmail.com>
	<alpine.LFD.2.11.1509282202270.7276@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Anand Gurram <anandarao.gurram@gmail.com>,
	NETDEV <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52368 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbbI1Vob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 17:44:31 -0400
In-Reply-To: <alpine.LFD.2.11.1509282202270.7276@ja.home.ssi.bg> (Julian
	Anastasov's message of "Mon, 28 Sep 2015 22:12:35 +0300 (EEST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julian Anastasov <ja@ssi.bg> writes:

> 	Hello,
>
> On Mon, 28 Sep 2015, Anand Gurram wrote:
>
>> I am currently using kernel version 3.16.7 on a linux switch.
>> While creating and destroying network namespaces I am observing below logs
>> on the console
>> "unregister_netdevice: waiting for lo to become free. Usage count = 1"
>> 
>> Can you please suggest and provide instructions on how to debug this issue.
>> If any fix already available can you please point me to the link.
>
> 	There are two commits from Linux 4.2 that may help:
>
> commit e9e4dd3267d0 ("net: do not process device backlog during unregistration")
> commit 2c17d27c36dc ("net: call rcu_read_lock early in process_backlog")
>
> 	For now I see them only in 3.2.71+ and 3.12.48+.
> I think, they will appear in other stable versions too...

If that message repeats indefinitely it means there is a leaked
reference to the network namespaces lo device.

If the message just spits out a few times and then goes away it simply
means that something is taking a while to cleanup and drop it's
reference.

This is slightly complicated by the fact that it is not uncommon when a
network device goes away to redirect all references to itself to the lo
device.

Eric
