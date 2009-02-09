From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [RFC] netlink broadcast return value
Date: Mon, 09 Feb 2009 23:51:54 +0100
Message-ID: <4990B38A.3020207@netfilter.org>
References: <4985A4C5.4050908@netfilter.org> <20090202.140533.121159038.davem@davemloft.net> <49903B03.2040302@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49903B03.2040302@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> David Miller wrote:
>> From: Pablo Neira Ayuso <pablo@netfilter.org>
>> Date: Sun, 01 Feb 2009 14:33:57 +0100
>>
>>> In short, I think that the change that I'm proposing would also require
>>> to fix some netlink_broadcast() clients to skip ENOBUFS errors: they are
>>> not meaningful for them since they assume that Netlink is unreliable and
>>> so the return value does not provide any useful information.
>>
>> I think this analysis is accurate.
> 
> We have at least one case where the caller wants to know of
> any successful delivery. Keymanager queries done by xfrm_state
> want to know whether an acquire was delivered to any keymanager.
> So we need to continue to indicate this, maybe using a different
> errno code than -ENOBUFS. I don't have a suggestion which one to
> use though.

Indeed, I have missed that spot. I'm not very familiar with that code,
however, I see that the creation of a state depends on the netlink
broadcast return value, but how useful is that? I think that the state
should be created even if the broadcast fails, the userspace daemon
should request a resync to the kernel as soon as it hits ENOBUFS, then
it would be in sync again with that state.

-- 
"Los honestos son inadaptados sociales" -- Les Luthiers
