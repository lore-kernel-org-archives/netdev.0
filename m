From: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] core, nfqueue,
 openvswitch: Orphan frags in skb_zerocopy and handle errors
Date: Wed, 19 Mar 2014 21:07:08 +0000
Message-ID: <532A06FC.5000001@citrix.com>
References: <1395261516-305-1-git-send-email-zoltan.kiss@citrix.com>
 <532A026E.5070609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Miklos Szeredi <mszeredi-AlSwsSmVLrQ@public.gmane.org>,
 kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 Jason Wang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
 Jan Beulich <JBeulich-IBi9RG/b67k@public.gmane.org>, Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
 Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
 Jozsef Kadlecsik <kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org>, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org,
 Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
 Paul Durrant <Paul.Durrant-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
 Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
 <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <532A026E.5070609-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 19/03/14 20:47, Thomas Graf wrote:
> On 03/19/2014 09:38 PM, Zoltan Kiss wrote:
>> skb_zerocopy can copy elements of the frags array between skbs, but it
>> doesn't
>> orphan them. Also, it doesn't handle errors, so this patch takes care
>> of that
>> as well.
>>
>> Signed-off-by: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
>> ---
>
>> +    if (unlikely(skb_orphan_frags(to, GFP_ATOMIC))) {
>> +        skb_tx_error(to);
>> +        return -ENOMEM;
>>       }
>
> I think you should move this down to right before we iterate over the
> frags.

I agree, I was mislead by that __skb_fill_page_desc, but now I see it is 
actually the head buffer of the source, not a frag from there. And in 
case of a failure in skb_copy_bits we can spare an orphan_frag.

Zoli
