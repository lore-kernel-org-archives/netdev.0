From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: fix curr_active_slave/carrier with
 loadbalance arp monitoring
Date: Wed, 19 Nov 2014 15:10:23 -0500 (EST)
Message-ID: <20141119.151023.684141809270754348.davem@davemloft.net>
References: <1416320084-25339-1-git-send-email-nikolay@redhat.com>
	<20141118143727.GA2643@raspberrypi>
	<20141118152847.GB2002@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vfalico@gmail.com, nikolay@redhat.com, netdev@vger.kernel.org,
	j.vosburgh@gmail.com, andy@greyhouse.net, dingtianhong@huawei.com
To: gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38239 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755749AbaKSUK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 15:10:26 -0500
In-Reply-To: <20141118152847.GB2002@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Date: Tue, 18 Nov 2014 10:28:47 -0500

> On Tue, Nov 18, 2014 at 03:37:27PM +0100, Veaceslav Falico wrote:
>> On Tue, Nov 18, 2014 at 03:14:44PM +0100, Nikolay Aleksandrov wrote:
>> >Since commit 6fde8f037e60 ("bonding: fix locking in
>> >bond_loadbalance_arp_mon()") we can have a stale bond carrier state and
>> >stale curr_active_slave when using arp monitoring in loadbalance modes. The
>> >reason is that in bond_loadbalance_arp_mon() we can't have
>> >do_failover == true but slave_state_changed == false, whenever do_failover
>> >is true then slave_state_changed is also true. Then the following piece
>> >from bond_loadbalance_arp_mon():
>> >               if (slave_state_changed) {
>> >                       bond_slave_state_change(bond);
>> >                       if (BOND_MODE(bond) == BOND_MODE_XOR)
>> >                               bond_update_slave_arr(bond, NULL);
>> >               } else if (do_failover) {
>> 
>> Ouch, must have been a big PITA to track :).
> 
> Agreed!
 ...
>> Acked-by: Veaceslav Falico <vfalico@gmail.com>
> 
> Acked-by: Andy Gospodarek <gospo@cumulusnetworks.com>

Applied, and queued up for -stable, thanks everyone!
