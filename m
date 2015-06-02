From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] rocker: remove support for legacy VLAN
 ndo ops
Date: Mon, 01 Jun 2015 22:24:42 -0700 (PDT)
Message-ID: <20150601.222442.1854333703599698362.davem@davemloft.net>
References: <1433183947-13095-1-git-send-email-sfeldma@gmail.com>
	<1433183947-13095-6-git-send-email-sfeldma@gmail.com>
	<556D363A.5010005@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, jiri@resnulli.us,
	simon.horman@netronome.com
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55259 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbbFBFYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 01:24:43 -0400
In-Reply-To: <556D363A.5010005@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Tue, 02 Jun 2015 13:51:06 +0900

> On 2015/06/02 3:39, sfeldma@gmail.com wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>> 
>> Remove support for legacy ndo ops
>> .ndo_vlan_rx_add_vid/.ndo_vlan_rx_kill_vid.  Rocker will use
>> bridge_setlink/dellink exclusively for VLAN add/del operations.
>> 
>> The legacy ops are needed if using 8021q driver module to setup VLANs on
>> the port.  But an alternative exists in using bridge_setlink/delink to
>> setup VLANs, which doesn't depend on 8021q module.  So rocker will switch
>> to the newer setlink/dellink ops.  VLANs can added/delete from the port,
>> regardless if port is bridged or not, using the bridge commands:
>> 
>> 	bridge vlan [add|del] vid VID dev DEV self
> 
> Hi Scott,
> 
> This doesn't look transparent with bridge.
> 
> Before this patch, I was able to add vid in the same way as software bridge:
> 
>   ip link set DEV master br0
>   bridge vlan add vid VID dev DEV
> 
> Now I need to add "self", which is different from software bridge...

I'm already not liking the looks of this....
