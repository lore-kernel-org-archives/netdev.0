From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 3/7] ipv6: improve ipv6_find_hdr() to
 skip empty routing headers
Date: Mon, 3 Dec 2012 09:28:55 -0800
Message-ID: <CAEP_g=-D6f-O1F0B4+xLKfZnY_LjFiHF-UaXD4zVUYctGG3-Ug@mail.gmail.com>
References: <1354214149-33651-1-git-send-email-jesse@nicira.com>
	<1354214149-33651-4-git-send-email-jesse@nicira.com>
	<20121203140458.GA1596@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Ansis Atteka <aatteka-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
To: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20121203140458.GA1596@1984>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 3, 2012 at 6:04 AM, Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org> wrote:
> On Thu, Nov 29, 2012 at 10:35:45AM -0800, Jesse Gross wrote:
>> @@ -159,9 +162,10 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
>>       }
>>       len = skb->len - start;
>>
>> -     while (nexthdr != target) {
>
> If the offset is set as parameter via ipv6_find_hdr, we now are always
> entering the loop even if we found the target header we're looking
> for, before that didn't happen.
>
> Something seems wrong here to me.

If the target header is a routing header then you might still need to
continue searching because the first one that you see could be empty.
