From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: unset primary slave via sysfs
Date: Tue, 29 Jan 2013 11:27:18 -0800
Message-ID: <31742.1359487638@death.nxdomain>
References: <269c3219-71dc-4802-81a4-562e61a1258c@zimbra>
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: Milos Vyletel <milos.vyletel@sde.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:54326 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754505Ab3A2T1d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 14:27:33 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 29 Jan 2013 14:27:32 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 876C638C804F
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 14:27:28 -0500 (EST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0TJRRoT295108
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 14:27:28 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0TJRJYf009371
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 12:27:20 -0700
In-reply-to: <269c3219-71dc-4802-81a4-562e61a1258c@zimbra>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Milos Vyletel <milos.vyletel@sde.cz> wrote:

>----- Original Message -----
>> Milos Vyletel <milos.vyletel@sde.cz> wrote:
>> 
>> >When bonding module is loaded with primary parameter and one decides
>> >to unset
>> >primary slave using sysfs these settings are not preserved during
>> >bond device
>> >restart. Primary slave is only unset once and it's not remembered in
>> >bond->params structure.
>> >
>> >Signed-off-by: Milos Vyletel <milos.vyletel@sde.cz>
>> 
>> 	I think the patch is fine, although I did prefer the longer
>> commit message from the initial version (the one that explained how
>> to
>> reproduce the problem).
>> 
>> 	-J
>> 
>> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
>> 
>
>Jay,
>
>just to be sure, do you want me to resend this patch again with the
>original commit message? It's no problem for me, I just don't want
>to spam this list when not necessary.

	Yes.  Detailed commit messages are not spam.

	-J

>Milos
>
>> 
>> >---
>> > drivers/net/bonding/bond_sysfs.c |    1 +
>> > 1 files changed, 1 insertions(+), 0 deletions(-)
>> >
>> >diff --git a/drivers/net/bonding/bond_sysfs.c
>> >b/drivers/net/bonding/bond_sysfs.c
>> >index ef8d2a0..155f3b4 100644
>> >--- a/drivers/net/bonding/bond_sysfs.c
>> >+++ b/drivers/net/bonding/bond_sysfs.c
>> >@@ -1067,6 +1067,7 @@ static ssize_t bonding_store_primary(struct
>> >device *d,
>> > 		pr_info("%s: Setting primary slave to None.\n",
>> > 			bond->dev->name);
>> > 		bond->primary_slave = NULL;
>> >+		memset(bond->params.primary, 0, sizeof(bond->params.primary));
>> > 		bond_select_active_slave(bond);
>> > 		goto out;
>> > 	}
>> >--
>> >1.7.1

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
