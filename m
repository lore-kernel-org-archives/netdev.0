From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH] cxgb4vf: fix crash due to manipulating queues before registration
Date: Thu, 28 Oct 2010 14:16:38 -0700
Message-ID: <197112BE-FC9F-4997-97DC-D740DF29C6DD@chelsio.com>
References: <1288297007-663-1-git-send-email-leedom@chelsio.com> <20101028.132122.245402585.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:19078 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477Ab0J1VQj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 17:16:39 -0400
In-Reply-To: <20101028.132122.245402585.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Oct 28, 2010, at 1:21 PM, David Miller wrote:

> From: Casey Leedom <leedom@chelsio.com>
> Date: Thu, 28 Oct 2010 13:16:47 -0700
> 
>> Before commit "net: allocate tx queues in register_netdevice"
>> netif_tx_stop_all_queues and related functions could be used between
>> device allocation and registration but now only after registration.
>> cxgb4 has such a call before registration and crashes now.  Move it
>> after register_netdev.
>> 
>> Signed-off-by: Casey Leedom <leedom@chelsio.com>
> 
> Why are you manipulating the queue at all here?
> 
> The queue state is "don't care" at this point in time,
> and has no meaning until ->open() is invoked.

True.  This driver was modeled on cxgb4, we wanted to make sure that the cxgb4 crash fix is ported to cxgb4vf.  Let me sync up with the other Chelsio maintainers.

Casey

