From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/5] bridge/ovs: avoid skb head copy on
 frame forwarding
Date: Tue, 01 Mar 2016 15:54:50 -0500 (EST)
Message-ID: <20160301.155450.1254691266298262681.davem@davemloft.net>
References: <cover.1456412101.git.pabeni@redhat.com>
	<CAOrHB_BGC2JnW=z0XYri-VioXsqY1tEuPpT1Ft1AStgU=Omfyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, pshelar@nicira.com, jesse@kernel.org,
	fbl@sysclose.org, hannes@stressinduktion.org,
	sergei.shtylyov@cogentembedded.com
To: pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41415 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbcCAUyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 15:54:52 -0500
In-Reply-To: <CAOrHB_BGC2JnW=z0XYri-VioXsqY1tEuPpT1Ft1AStgU=Omfyg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pravin shelar <pshelar@ovn.org>
Date: Mon, 29 Feb 2016 11:05:18 -0800

> On Fri, Feb 26, 2016 at 1:45 AM, Paolo Abeni <pabeni@redhat.com> wrote:
>> Currently, while when an OVS or Linux bridge is used to forward frames towards
>> some tunnel device, a skb_head_copy() may occur if the ingress device do not
>> provide enough headroom for the tx encapsulation.
>>
>> This patch series tries to address the issue implementing a new ndo operation to
>> allow the master device to control the headroom used when allocating the skb on
>> frame reception.
>>
>> Said operation is used by the Linux bridge to notify the bridged ports of
>> needed_headroom changes, and similar bookkeeping and behaviour is also added to
>> openvswitch, on a per datapath basis.
>>
>> Finally, the operation is implemented for veth and tun device, which give
>> performance improvement in the 6-12% range when forwarding frames from said
>> devices towards a vxlan tunnel.
>>
>> v2:
>> - fix netdev_get_fwd_headroom() behaviour
>> - remove some code duplication with the netdev_set_rx_headroom() and
>>    netdev_reset_rx_headroom() helpers
>> - handle headroom reset on [v]port removal/deletion
>> - initialize tun align to the old default value
>>
>> v3:
>> - fix a comment typo
>>
> Patch series looks good to me.
> 
> Acked-by: Pravin B Shelar <pshelar@ovn.org>

Series applied, thanks everyone.
