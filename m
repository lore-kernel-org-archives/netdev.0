From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH net-next 00/11] netns: don't switch namespace while creating kernel sockets
Date: Thu, 07 May 2015 13:58:29 -0500
Message-ID: <87twvob4fe.fsf@x220.int.ebiederm.org>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
	<87wq0kcqlm.fsf@x220.int.ebiederm.org>
	<CAHA+R7NuxGDnCSfVXJ4tcqYNZGu6RetYLvtrMo4SSqRFHKCFPg@mail.gmail.com>
	<871tisckgr.fsf@x220.int.ebiederm.org>
	<CAHA+R7POE-X0Tbn6XEGSta=tDZQ_+EDg0ruSxy3qMFNm9Rd0oQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ying Xue <ying.xue@windriver.com>, netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Pavel Emelyanov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, maxk@qti.qualcomm.com,
	Stephen Hemminger <stephen@networkplumber.org>,
	Thomas Graf <tgraf@suug.ch>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Tom Herbert <tom@herbertland.com>,
	James Chapman <jchapman@katalix.com>,
	Erik Hugne <erik.hugne@ericsson.com>, jon.maloy@ericsson.com,
	Simon Horman <horms@verge.net.au>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:39221 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbbEGTDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 15:03:07 -0400
In-Reply-To: <CAHA+R7POE-X0Tbn6XEGSta=tDZQ_+EDg0ruSxy3qMFNm9Rd0oQ@mail.gmail.com>
	(Cong Wang's message of "Thu, 7 May 2015 11:53:32 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <cwang@twopensource.com> writes:

> On Thu, May 7, 2015 at 11:26 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>> Cong Wang <cwang@twopensource.com> writes:
>>
>>>
>>> Why does this have to be so complicated? We can simply avoid
>>> calling ops_init() by skipping those in cleanup_list, no?
>>
>> The problem is that there is a single list of methods to call and if you
>> simply skip calling the initialization methods for a struct net and add
>> yourself to the list cleanup_net will then call the cleanup methods
>> without calling the cleanup methods.
>
> If you mean pernet_list, ops->list has been already added before
> for_each_net().
>
>>
>> Simply limiting new network namespace registrations to a point when
>> network namespaces are not being registered or unregisted seems like
>> the simplest way to achieve this effect.
>>
>
> Literally, any point before ops_init().

Think about what that what it means to add a set of operations to the
pernet_list and then to skip a network namespace with a count of 0 and
then to have that network namespace exit with those methods on
pernet_list.

Eric
