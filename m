From: Nikolay Aleksandrov via Bridge <bridge@lists.linux-foundation.org>
Subject: Re: [PATCH net-next v2 2/2] net: bridge: add per-port
 multicast flood flag
Date: Wed, 31 Aug 2016 08:02:22 +0200
Message-ID: <7d1fc865-f092-5d9d-8f4c-f19aeac914c0@cumulusnetworks.com>
References: <1472570588-32503-1-git-send-email-nikolay@cumulusnetworks.com>
	<1472570588-32503-3-git-send-email-nikolay@cumulusnetworks.com>
	<20160831013726.GD4883@otheros>
Reply-To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	bridge@lists.linux-foundation.org, davem@davemloft.net
To: =?UTF-8?Q?Linus_L=c3=bcssing?= <linus.luessing@c0d3.blue>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20160831013726.GD4883@otheros>
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

On 31/08/16 03:37, Linus Lüssing wrote:
> On Tue, Aug 30, 2016 at 05:23:08PM +0200, Nikolay Aleksandrov via Bridge wrote:
>> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>> index 1da3221845f1..ed0dd3340084 100644
>> --- a/net/bridge/br_if.c
>> +++ b/net/bridge/br_if.c
>> @@ -362,7 +362,7 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
>>  	p->path_cost = port_cost(dev);
>>  	p->priority = 0x8000 >> BR_PORT_BITS;
>>  	p->port_no = index;
>> -	p->flags = BR_LEARNING | BR_FLOOD;
>> +	p->flags = BR_LEARNING | BR_FLOOD | BR_MCAST_FLOOD;
> 
> I'm discontent with this new flag becoming the default.
> 
> Could you elaborate a little more on your use-case, when/why do
> you want/need this flag?
> 

The use case is the current default behaviour if we don't make this flag on by default
then we'll change user-visible default behaviour. Right now we flood unregistered mcast
traffic by default (if there's no querier and router port, which continues to function
as before). Also we have the port flags equal to BR_AUTO_MASK by default.

Cheers,
 Nik
