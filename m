From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH 1/1] bond: relocate rcu_read_lock and rcu_read_unlock
Date: Mon, 1 Feb 2016 12:08:05 +0100
Message-ID: <56AF3C95.3040606@cumulusnetworks.com>
References: <1454297472-24261-1-git-send-email-zyjzyj2000@gmail.com>
 <56AF3B24.7000207@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: zyjzyj2000@gmail.com, j.vosburgh@gmail.com, vfalico@gmail.com,
	gospo@cumulusnetworks.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:34641 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752956AbcBALII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 06:08:08 -0500
Received: by mail-wm0-f52.google.com with SMTP id 128so65240586wmz.1
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 03:08:08 -0800 (PST)
In-Reply-To: <56AF3B24.7000207@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/01/2016 12:01 PM, Nikolay Aleksandrov wrote:
> On 02/01/2016 04:31 AM, zyjzyj2000@gmail.com wrote:
>> From: Zhu Yanjun <zyjzyj2000@gmail.com>
>>
>> rcu_read_lock and rcu_read_unlock are to protect the function
>> bond_miimon_inspect. As such, moving rcu_read_lock and rcu_read_unlock
>> to the function bond_miimon_inspect to make the source code compact.
>>
>> CC: Jay Vosburgh <j.vosburgh@gmail.com>
>> CC: Veaceslav Falico <vfalico@gmail.com>
>> CC: Andy Gospodarek <gospo@cumulusnetworks.com>
>> Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
>> ---
>>  drivers/net/bonding/bond_main.c | 9 ++++-----
>>  1 file changed, 4 insertions(+), 5 deletions(-)
>>
> 
> Not true, RCU also protects the slave dereference in bond_should_notify_peers().
> Even though there's already a rcu_read_lock() while doing the dereference
> itself, it is there only to please RCU, IIRC. The only "simplification" you

Err, I meant to please lockdep when being called with RTNL.

> can do is remove the rcu_read_lock/unlock() around the slave deref in
> bond_should_notify_peers and use rcu_dereference_rtnl() as it can be used either
> in RCU protected region or with RTNL held. Also I think net-next is still
> closed (and that's where this should be targeted at).
> 
> Cheers,
>  Nik
> 
> 
