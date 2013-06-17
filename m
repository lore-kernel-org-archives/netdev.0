From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] bonding: don't call
 alb_set_slave_mac_addr() while atomic
Date: Mon, 17 Jun 2013 16:27:49 -0700 (PDT)
Message-ID: <20130617.162749.2209130543094101091.davem@davemloft.net>
References: <1371490235-4448-1-git-send-email-vfalico@redhat.com>
	<51BF4B7F.5000101@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, netdev@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40403 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361Ab3FQX1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 19:27:50 -0400
In-Reply-To: <51BF4B7F.5000101@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Mon, 17 Jun 2013 19:46:39 +0200

> On 17/06/13 19:30, Veaceslav Falico wrote:
>> alb_set_slave_mac_addr() sets the mac address in alb mode via
>> dev_set_mac_address(), which might sleep. It's called from
>> alb_handle_addr_collision_on_attach() in atomic context (under
>> read_lock(bond->lock)), thus triggering a bug.
>> 
>> Fix this by moving the lock inside alb_handle_addr_collision_on_attach().
>> 
>> v1->v2:
>> As Nikolay Aleksandrov noticed, we can drop the bond->lock completely.
>> Also, use bond_slave_has_mac(), when possible.
>> 
>> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>> ---
>>  drivers/net/bonding/bond_alb.c | 40 +++++-----------------------------------
>>  1 file changed, 5 insertions(+), 35 deletions(-)
>> 
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Applied.
