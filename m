From: "Denis V. Lunev" <dlunev@gmail.com>
Subject: Re: [NETNS] Oops in register_pernet_operations() with CONFIG_NET_NS=n
Date: Thu, 25 Oct 2007 20:52:09 +0400
Message-ID: <4720C9B9.80706@gmail.com>
References: <47209317.8000802@bull.net> <4720A181.3060003@sw.ru>	<4720AD20.5030902@bull.net> <m17ilb6xs9.fsf@ebiederm.dsl.xmission.com>	<4720B1EE.8050507@bull.net> <m1y7dr5esy.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Benjamin Thery <benjamin.thery@bull.net>,
	Pavel Emelianov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Cedric Le Goater <clg@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:10098 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753843AbXJYQt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 12:49:28 -0400
Received: by ug-out-1314.google.com with SMTP id z38so538639ugc
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2007 09:49:27 -0700 (PDT)
In-Reply-To: <m1y7dr5esy.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Benjamin Thery <benjamin.thery@bull.net> writes:
> 
>> Eric W. Biederman wrote:
>>> Benjamin Thery <benjamin.thery@bull.net> writes:
>>>
>>>> Denis V. Lunev wrote:
>>>>> The patch attached should help. The idea is simple. The "init" should be
>>>>> called only once without NETNS. Period. No need for any lists.
>>>> This is the kind of idea I had but I didn't think it could be 
>>>> that simple. :) 
>>>> Thanks Denis.
>>> It isn't.

this will work due to INIT_LIST_HEAD with circles list to itself and a
del operation will work.

By the way, I think that we can in the case of undefined CONFIG_NET_NS
reduce register to calling ->init method and unregister to calling
->exit method.

This is a correct thing at least for now and will be welcomed by the all
embedded/etc people.

Regards,
	Den
