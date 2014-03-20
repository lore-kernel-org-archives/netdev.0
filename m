From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH v2] core, nfqueue, openvswitch: Orphan frags in skb_zerocopy
 and handle errors
Date: Thu, 20 Mar 2014 16:01:59 +0000
Message-ID: <532B10F7.60801@citrix.com>
References: <1395263249-16450-1-git-send-email-zoltan.kiss@citrix.com> <532ADC33.5040607@redhat.com> <532AE010.9050903@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Tom Herbert <therbert@google.com>,
	Jason Wang <jasowang@redhat.com>,
	Florian Westphal <fw@strlen.de>, Joe Perches <joe@perches.com>,
	Simon Horman <horms@verge.net.au>,
	Jiri Pirko <jiri@resnulli.us>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Jan Beulich <JBeulich@suse.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Miklos Szeredi <mszeredi@suse.cz>,
	<netfilter-devel@vger.kernel.org>, <netfilter@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <kvm@vger.kernel.org>
To: Thomas Graf <tgraf@redhat.com>, Jesse Gross <jesse@nicira.com>,
	<pshelar@nicira.com>, <dev@openvswitch.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <532AE010.9050903@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/03/14 12:33, Thomas Graf wrote:
> On 03/20/2014 01:16 PM, Thomas Graf wrote:
>> On 03/19/2014 10:07 PM, Zoltan Kiss wrote:
>>> skb_zerocopy can copy elements of the frags array between skbs, but it
>>> doesn't
>>> orphan them. Also, it doesn't handle errors, so this patch takes care
>>> of that
>>> as well.
>>>
>>> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
>>
>> Acked-by: Thomas Graf <tgraf@redhat.com>
>
> I take this back ;)
>
>>> ---
>>> +    if (unlikely(skb_orphan_frags(to, GFP_ATOMIC))) {
>>> +        skb_tx_error(to);
>>> +        return -ENOMEM;
>>> +    }
>
> Just noticed that you orphan the Netlink skb frags which do not
> exist yet instead of the source skb frags.
Oh, sorry, I'll fix this up.

>
>> Did you consider calling skb_tx_error() for Netlink message
>> allocation failures for the upcall as well? That memory pressure
>> is currently not reported back.
Yeah, that makes sense, I'll fix it the callers. Btw. I guess that just 
provides some statistical data for the creator of the skb. At least for 
netback it only increment a stat counter.

Zoli


