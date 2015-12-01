From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: memory leak in do_ipv6_setsockopt
Date: Tue, 01 Dec 2015 15:49:07 +0100
Message-ID: <565DB363.6030702@iogearbox.net>
References: <CACT4Y+bv56b+opCd=5SHmN47MAHEFyZA18kSsu-Fa+XODj20PA@mail.gmail.com>	 <1448977016.25582.18.camel@edumazet-glaptop2.roam.corp.google.com>	 <565DA9BE.3060006@iogearbox.net>	 <1448979404.25582.23.camel@edumazet-glaptop2.roam.corp.google.com>	 <565DAD8D.9020800@iogearbox.net> <1448980723.25582.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org, syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59804 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755605AbbLAOt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 09:49:27 -0500
In-Reply-To: <1448980723.25582.24.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/2015 03:38 PM, Eric Dumazet wrote:
> On Tue, 2015-12-01 at 15:24 +0100, Daniel Borkmann wrote:
>> On 12/01/2015 03:16 PM, Eric Dumazet wrote:
>>> On Tue, 2015-12-01 at 15:07 +0100, Daniel Borkmann wrote:
>>>
>>>> Yeah, we miss inet6_destroy_sock() in SCTP. :-(
>>>>
>>>> Looks good to me.
>>>
>>> OK, I will send a formal (and tested ;) ) patch.
>>
>> I was shortly wondering whether there could be a use-after-free by
>> doing this after sctp_destroy_sock() due to the sctp_endpoint_destroy()
>> that would eventually drop a ref on the socket, but the endpoint holds
>> a separate ref, so we should be good.
>
> More generically ->destroy() caller must keep a reference on the socket.
>
> inet_csk_destroy_sock() for example uses sk after
>
> sk->sk_prot->destroy(sk);

Right, and later on, we might call into ->sk_destruct() when there are no
more refs (in SCTP case: sctp_destruct_sock()).

Thanks,
Daniel
