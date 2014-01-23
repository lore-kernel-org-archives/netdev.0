From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v2 net-next 05/12] bonding: extend arp_validate to be
 able to receive unvalidated arp-only traffic
Date: Thu, 23 Jan 2014 11:25:29 +0100
Message-ID: <20140123102529.GA15320@redhat.com>
References: <1389977940-17084-1-git-send-email-vfalico@redhat.com>
 <1389977940-17084-6-git-send-email-vfalico@redhat.com>
 <32086.1389991289@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56993 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752880AbaAWK2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jan 2014 05:28:31 -0500
Content-Disposition: inline
In-Reply-To: <32086.1389991289@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 17, 2014 at 12:41:29PM -0800, Jay Vosburgh wrote:
>Veaceslav Falico <vfalico@redhat.com> wrote:
...snip...
>>--- a/drivers/net/bonding/bonding.h
>>+++ b/drivers/net/bonding/bonding.h
>>@@ -318,6 +318,11 @@ static inline bool bond_is_active_slave(struct slave *slave)
>> #define BOND_ARP_VALIDATE_BACKUP	(1 << BOND_STATE_BACKUP)
>> #define BOND_ARP_VALIDATE_ALL		(BOND_ARP_VALIDATE_ACTIVE | \
>> 					 BOND_ARP_VALIDATE_BACKUP)
>>+#define BOND_ARP_VALIDATE_ARP		(BOND_ARP_VALIDATE_ALL + 1)
>>+#define BOND_ARP_VALIDATE_ACTIVE_ARP	(BOND_ARP_VALIDATE_ACTIVE | \
>>+					 BOND_ARP_VALIDATE_ARP)
>>+#define BOND_ARP_VALIDATE_BACKUP_ARP	(BOND_ARP_VALIDATE_BACKUP | \
>>+					 BOND_ARP_VALIDATE_ARP)
>
>	If you go with my suggestion to call the new thing "filtering,"
>I'd change these option names, labels, and the function
>"slave_do_arp_validate_only" names.  The function name seems kind of
>confusing in particular. I think it'd be clearer to replace the
>"validate" stuff with "filter."

Hi Jay,

Sorry for the delay. Yep, completely agree, I'll change the doc/rename the
functions/defines to use "filtering" instead of double-arp.

I'll re-send it once I'll fix the current bonding state...

Thank you!

>
>	-J
>
>> static inline int slave_do_arp_validate(struct bonding *bond,
>> 					struct slave *slave)
>>@@ -325,6 +330,12 @@ static inline int slave_do_arp_validate(struct bonding *bond,
>> 	return bond->params.arp_validate & (1 << bond_slave_state(slave));
>> }
>>
>>+static inline int slave_do_arp_validate_only(struct bonding *bond,
>>+					     struct slave *slave)
>>+{
>>+	return bond->params.arp_validate & BOND_ARP_VALIDATE_ARP;
>>+}
>>+
>> /* Get the oldest arp which we've received on this slave for bond's
>>  * arp_targets.
>>  */
>>--
>>1.8.4
>>
>
>---
>	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>
