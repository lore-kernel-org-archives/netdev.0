From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v5 2/2] netfilter: save the hash of the tuple in the original
 direction for latter use
Date: Tue, 21 Sep 2010 17:32:18 +0200
Message-ID: <4C98D002.3000309@trash.net>
References: <1282344540-5306-1-git-send-email-xiaosuo@gmail.com> <4C91B6BE.8020300@trash.net> <AANLkTikZeFrS9pj6jxmOxqY6dsaAf1U+FAXe5jNwQ-nV@mail.gmail.com> <4C979515.4060908@trash.net> <AANLkTi=NXj9PjYA06+UFYms8q5K3Z4DsPMcpVHpj7Gmq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	akpm@linux-foundation.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=NXj9PjYA06+UFYms8q5K3Z4DsPMcpVHpj7Gmq@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 21.09.2010 02:02, schrieb Changli Gao:
> On Tue, Sep 21, 2010 at 1:08 AM, Patrick McHardy <kaber@trash.net> wrote:
>>
>> Sure we can, dropping unconfirmed conntracks is a rare exception,
>> not a common case. Even under DoS we usually drop *unassured*
>> conntracks, which have already enterered the hash. If we're unable
>> to do that, we won't even allocate a new conntrack.
>>
> 
> Even so, saving the hash of the reply tuple isn't a good idea.
> 
> If NAT is turned on, the current code is:
> 
> mangle the reply tuple -> compute the hash of the reply tuple ->
> insert into the conntrack hash table.
> 
> the new code is
> 
> compute the hash of the reply tuple -> mangle the reply tuple ->
> recompute the hash of the reply tuple -> insert into the conntrack
> hash table.
> 
> As you see, the hash computing is done twice, and we use more CPU
> cycles than before.

You're right of course, we actually don't compute the reply hash
before inserting the conntrack into the hash table (except in a
few NAT cases, but we can look at those later).
