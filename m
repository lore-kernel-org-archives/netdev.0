From: Nikolay Aleksandrov via Bridge <bridge@lists.linux-foundation.org>
Subject: Re: [PATCH net-next 1/2] net: bridge: change unicast
 boolean to exact pkt_type
Date: Tue, 30 Aug 2016 17:10:59 +0200
Message-ID: <640052a4-b675-b9a5-2c5c-63dc227dae93@cumulusnetworks.com>
References: <1472562539-23247-1-git-send-email-nikolay@cumulusnetworks.com>
	<1472562539-23247-2-git-send-email-nikolay@cumulusnetworks.com>
	<20160830075953.739291e1@xeon-e3>
	<1344bd99-cc38-2dda-4875-337796892685@cumulusnetworks.com>
Reply-To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com, davem@davemloft.net,
	bridge@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1344bd99-cc38-2dda-4875-337796892685@cumulusnetworks.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 30/08/16 17:00, Nikolay Aleksandrov wrote:
> On 30/08/16 16:59, Stephen Hemminger wrote:
[snip]
>>>  	if (p->state == BR_STATE_LEARNING)
>>>  		goto drop;
>>>  
>>>  	BR_INPUT_SKB_CB(skb)->brdev = br->dev;
>>>  
>>> -	local_rcv = !!(br->dev->flags & IFF_PROMISC);
>>> -
>>>  	if (IS_ENABLED(CONFIG_INET) && skb->protocol == htons(ETH_P_ARP))
>>>  		br_do_proxy_arp(skb, br, vid, p);
>>>
>>
>> can't proxy_arp change what was a broadcast packet into a unicast packet?
>>
> 

Sorry I missed this question, no it shouldn't be possible. The proxy arp
code only inspects the skb and acts accordingly, it doesn't do any
modifications IIRC.
