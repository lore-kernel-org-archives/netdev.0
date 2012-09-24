From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCHv3 net-next 3/3] vxlan: virtual extensible lan
Date: Mon, 24 Sep 2012 16:17:37 -0700
Message-ID: <5060EA11.1040003@intel.com>
References: <20120924184304.727711327@vyatta.com> <20120924185050.162920909@vyatta.com> <1348515547.26828.1538.camel@edumazet-glaptop> <20120924124657.4541c186@nehalam.linuxnetplumber.net> <1348516500.26828.1570.camel@edumazet-glaptop> <20120924130239.18767146@nehalam.linuxnetplumber.net> <5060C189.8090803@intel.com> <20120924132753.04c20647@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Chris Wright <chrisw@redhat.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:13040 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750831Ab2IXXRo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 19:17:44 -0400
In-Reply-To: <20120924132753.04c20647@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>>
>> [...]
>>
>>> +	err = ip_local_out(skb);
>>> +	if (likely(net_xmit_eval(err) == 0)) {
>>> +		struct vxlan_stats *stats = this_cpu_ptr(vxlan->stats);
>>> +
>>> +		u64_stats_update_begin(&stats->syncp);
>>> +		stats->tx_packets++;
>>> +		stats->tx_bytes += pkt_len;
>>
>> Should pkt_len include the outer headers?
>
> It doesn't for GRE and related tunnels.
>

OK best to keep it the same as other tunnels.
