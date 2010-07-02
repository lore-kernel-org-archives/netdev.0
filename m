From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/9] netfilter: nf_nat: support user-specified SNAT rules
 in LOCAL_IN
Date: Fri, 02 Jul 2010 12:17:55 +0200
Message-ID: <4C2DBCD3.20208@trash.net>
References: <1278064342-19059-1-git-send-email-kaber@trash.net> <1278064342-19059-2-git-send-email-kaber@trash.net> <alpine.LSU.2.01.1007021212490.16691@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1007021212490.16691@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Friday 2010-07-02 11:52, kaber@trash.net wrote:
>   
>> 2.6.34 introduced 'conntrack zones' to deal with cases where packets
>>     
> >from multiple identical networks are handled by conntrack/NAT. Packets
>   
>> are looped through veth devices, during which they are NATed to private
>> addresses, after which they can continue normally through the stack
>> and possibly have NAT rules applied a second time.
>>
>> This works well, but is needlessly complicated for cases where only
>> a single SNAT/DNAT mapping needs to be applied to these packets.
>>     
>
> I still have not grasped why SNAT is needed in the INPUT path. For the
> tunnel scenario that you wanted to build I could not find a reason to
> do SNAT in that place - since the non-encapsulated packets don't go
> through INPUT anyway.
>   

Sure they do, if they are destined for the host itself. I'm not sure
what's so hard to understand about this patch, you have f.i. multiple
tunnels using the same remote network, on INPUT and POSTROUTING you SNAT
them to seperate networks based on criteria like the network device or
the IPsec tunnel to be able to distinguish them.
