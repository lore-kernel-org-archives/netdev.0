From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC PATCH net-next 00/11] netns: don't switch namespace while
 creating kernel sockets
Date: Thu, 7 May 2015 11:53:32 -0700
Message-ID: <CAHA+R7POE-X0Tbn6XEGSta=tDZQ_+EDg0ruSxy3qMFNm9Rd0oQ@mail.gmail.com>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
	<87wq0kcqlm.fsf@x220.int.ebiederm.org>
	<CAHA+R7NuxGDnCSfVXJ4tcqYNZGu6RetYLvtrMo4SSqRFHKCFPg@mail.gmail.com>
	<871tisckgr.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:34790 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246AbbEGSxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 14:53:33 -0400
Received: by wgic8 with SMTP id c8so26035426wgi.1
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 11:53:32 -0700 (PDT)
In-Reply-To: <871tisckgr.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 7, 2015 at 11:26 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Cong Wang <cwang@twopensource.com> writes:
>
>>
>> Why does this have to be so complicated? We can simply avoid
>> calling ops_init() by skipping those in cleanup_list, no?
>
> The problem is that there is a single list of methods to call and if you
> simply skip calling the initialization methods for a struct net and add
> yourself to the list cleanup_net will then call the cleanup methods
> without calling the cleanup methods.

If you mean pernet_list, ops->list has been already added before
for_each_net().

>
> Simply limiting new network namespace registrations to a point when
> network namespaces are not being registered or unregisted seems like
> the simplest way to achieve this effect.
>

Literally, any point before ops_init().
