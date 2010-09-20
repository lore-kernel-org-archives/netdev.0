From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v5 2/2] netfilter: save the hash of the tuple in the original
 direction for latter use
Date: Mon, 20 Sep 2010 19:08:37 +0200
Message-ID: <4C979515.4060908@trash.net>
References: <1282344540-5306-1-git-send-email-xiaosuo@gmail.com> <4C91B6BE.8020300@trash.net> <AANLkTikZeFrS9pj6jxmOxqY6dsaAf1U+FAXe5jNwQ-nV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	akpm@linux-foundation.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikZeFrS9pj6jxmOxqY6dsaAf1U+FAXe5jNwQ-nV@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20.09.2010 17:04, Changli Gao wrote:
> On Thu, Sep 16, 2010 at 2:18 PM, Patrick McHardy <kaber@trash.net> wrote:
>> On 21.08.2010 00:49, Changli Gao wrote:
>>> Since we don't change the tuple in the original direction, we can save it
>>> in ct->tuplehash[IP_CT_DIR_REPLY].hnode.pprev for __nf_conntrack_confirm()
>>> use.
>>
>> I like this idea. We could actually do the same for the reply tuple
>> and invalidate the saved hash in case the reply tuple is changed
>> (nf_conntrack_alter_reply()), which only happens when NAT is used.
>>
> 
> We can't do that, as the unconfirmed ct owned maybe dropped, and
> pre-computing will wast CPU cycles in this case.

Sure we can, dropping unconfirmed conntracks is a rare exception,
not a common case. Even under DoS we usually drop *unassured*
conntracks, which have already enterered the hash. If we're unable
to do that, we won't even allocate a new conntrack.
