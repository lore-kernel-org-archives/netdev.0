From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 1/5] bonding: convert to list API and replace
 bond's custom list
Date: Wed, 31 Jul 2013 20:44:49 +0200
Message-ID: <51F95B21.5020004@redhat.com>
References: <1375283553-32070-1-git-send-email-nikolay@redhat.com> <1375283553-32070-2-git-send-email-nikolay@redhat.com> <20130731113717.32f48d71@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net,
	fubar@us.ibm.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63622 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757210Ab3GaSpA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 14:45:00 -0400
In-Reply-To: <20130731113717.32f48d71@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/31/2013 08:37 PM, Stephen Hemminger wrote:
> On Wed, 31 Jul 2013 17:12:29 +0200
> Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> 
>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>> index 390061d..80e288c 100644
>> --- a/drivers/net/bonding/bond_3ad.c
>> +++ b/drivers/net/bonding/bond_3ad.c
>> @@ -143,10 +143,13 @@ static inline struct bonding *__get_bond_by_port(struct port *port)
>>   */
>>  static inline struct port *__get_first_port(struct bonding *bond)
>>  {
>> +	struct slave *first_slave;
>> +
>>  	if (bond->slave_cnt == 0)
>>  		return NULL;
>> +	first_slave = bond_first_slave(bond);
> 
> As Jay said, it would be be better to have bond_first_slave return
> NULL (if no slaves), and eliminate slave_cnt. It would also fix
> a race here between slave_cnt and all slave's being removed.
> 
Hi Stephen,
First off - thank you for the review.

What do you mean by eliminate slave_cnt ?
We need it for various calculations throughout the bonding.
There's no race here because read_lock(&bond->lock) is held every time this
is called and slave_cnt can change only under write_lock of the same lock,
the 3ad code is not yet converted to RCU.

Nik
