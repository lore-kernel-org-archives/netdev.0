From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net] bridge: clean the nf_bridge status when forwarding
 the skb
Date: Fri, 18 Oct 2013 11:33:06 -0400
Message-ID: <526154B2.2060900@redhat.com>
References: <1381791096-3561-1-git-send-email-antonio@meshcoding.com> <20131017112857.GA11318@localhost> <20131017113735.GB2699@open-mesh.com> <20131018111041.GA10964@localhost> <20131018113555.GK2596@neomailbox.net> <52614669.5040301@redhat.com> <20131018144618.GL2596@neomailbox.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Antonio Quartulli <antonio@open-mesh.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Antonio Quartulli <antonio@meshcoding.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12582 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752338Ab3JRPdQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 11:33:16 -0400
In-Reply-To: <20131018144618.GL2596@neomailbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2013 10:46 AM, Antonio Quartulli wrote:
> On Fri, Oct 18, 2013 at 10:32:09AM -0400, Vlad Yasevich wrote:
>> On 10/18/2013 07:35 AM, Antonio Quartulli wrote:
>>> On Fri, Oct 18, 2013 at 01:10:41PM +0200, Pablo Neira Ayuso wrote:
>>>> On Thu, Oct 17, 2013 at 01:37:35PM +0200, Antonio Quartulli wrote:
>>>>> On Thu, Oct 17, 2013 at 04:28:57AM -0700, Pablo Neira Ayuso wrote:
>
> [...]
>
>>>
>>> The problem I was having was due to an skb entering br0 first and br1 later.
>>> When reaching br1 skb->nf_bridge was != NULL because of the previous processing
>>> in br0.
>>>
>>
>> Doesn't br_nf_pre_routing already take care of this for you?  It will
>> drop the ref on the current nf_bridge and allocate a new one.  Is that
>> not sufficient?
>
> In my case that line is not reached because
>
>   700         if (!IS_IP(skb) && !IS_VLAN_IP(skb) && !IS_PPPOE_IP(skb))
>
> is always true: the packet getting analysed is a batman-adv encapsulated packet,
> which does not match any of the three above.
>
> Cheers,
>

Looking at other encapsulators (PPP, iptunnel, VXLAN), they do
nf_reset() on input.  Would that be appropriate for batman as well?

-vlad
