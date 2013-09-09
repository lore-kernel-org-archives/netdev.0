From: Jason Wang <jasowang@redhat.com>
Subject: Re: TSQ accounting skb->truesize degrades throughput for large packets
Date: Mon, 09 Sep 2013 17:27:02 +0800
Message-ID: <522D9466.6020205@redhat.com>
References: <20130906101635.GI14104@zion.uk.xensource.com>  <1378472268.31445.15.camel@edumazet-glaptop> <522A049A.7000105@citrix.com> <1378486604.31445.34.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Jonathan Davies <Jonathan.Davies@eu.citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58303 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750871Ab3IIJ2S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Sep 2013 05:28:18 -0400
In-Reply-To: <1378486604.31445.34.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2013 12:56 AM, Eric Dumazet wrote:
> On Fri, 2013-09-06 at 17:36 +0100, Zoltan Kiss wrote:
>> On 06/09/13 13:57, Eric Dumazet wrote:
>>> Well, I have no problem to get line rate on 20Gb with a single flow, so
>>> other drivers have no problem.
>> I've made some tests on bare metal:
>> Dell PE R815, Intel 82599EB 10Gb, 3.11-rc4 32 bit kernel with 3.17.3 
>> ixgbe (TSO, GSO on), iperf 2.0.5
>> Transmitting packets toward the remote end (so running iperf -c on this 
>> host) can make 8.3 Gbps with the default 128k tcp_limit_output_bytes. 
>> When I increased this to 131.506 (128k + 434 bytes) suddenly it jumped 
>> to 9.4 Gbps. Iperf CPU usage also jumped a few percent from ~36 to ~40% 
>> (softint percentage in top also increased from ~3 to ~5%)
> Typical tradeoff between latency and throughput
>
> If you favor throughput, then you can increase tcp_limit_output_bytes
>
> The default is quite reasonable IMHO.
>
>> So I guess it would be good to revisit the default value of this 
>> setting. What hw you used Eric for your 20Gb results?
> Mellanox CX-3
>
> Make sure your NIC doesn't hold TX packets in TX ring too long before
> signaling an interrupt for TX completion.

Virtio-net orphan the skb in .ndo_start_xmit() so TSQ can not throttle
packets in device accurately, and it also can't do BQL. Does this means
TSQ should be disabled for virtio-net?
