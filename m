From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] reduce netfilte sk_buff enlargement
Date: Wed, 20 Jul 2005 23:35:09 +0200
Message-ID: <42DEC38D.8070102@trash.net>
References: <20050717220451.GB13434@rama.risq.ericsson.ca>
	<20050718.203145.105430424.davem@davemloft.net>
	<20050720132305.GA4077@rama>
	<Pine.LNX.4.63.0507202335530.1564@penguin.linux-vs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, netdev@vger.kernel.org,
	Marcel Holtmann <marcel@holtmann.org>, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Wensong Zhang <wensong@linux-vs.org>
In-Reply-To: <Pine.LNX.4.63.0507202335530.1564@penguin.linux-vs.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Wensong Zhang wrote:
>> Well, I hope IPVS people will take care of this.  I don't really know
>> that code too well...
>>
> This bit is only to indicate that the sk_buff is already mangled by 
> IPVS/NAT, so that when both iptables/NAT and IPVS/NAT are enabled, 
> iptables/NAT will not mangle sk_buff again. I am not sure if there is 
> more elegant way to work around this issue, will investigate it.

For new connections you could set the IPS_SRC_NAT_DONE and
IPS_DST_NAT_DONE bits in conntrack->status to avoid NAT setting up
new mappings. But this doesn't work if IPVS is loaded when NAT
has already set up the mappings. In this case you could refuse
to NAT in IPVS.

Regards
Patrick
