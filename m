From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next] bonding: net_ratelimit() pr_warn()s in 802.3ad
 mode
Date: Sun, 16 Mar 2014 18:02:36 +0100
Message-ID: <20140316170236.GD30498@redhat.com>
References: <1394987380-15765-1-git-send-email-vfalico@redhat.com>
 <1394989163.5689.42.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52634 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751219AbaCPRCs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Mar 2014 13:02:48 -0400
Content-Disposition: inline
In-Reply-To: <1394989163.5689.42.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 16, 2014 at 09:59:23AM -0700, Joe Perches wrote:
>On Sun, 2014-03-16 at 17:29 +0100, Veaceslav Falico wrote:
>> Only ratelimit the ones that might spam, omiting the ones from
>> enslave/deslave.
>
>No, this patch isn't good and must not be applied.
>You've also changed flow here.

Hrm, seems like geomagnetic storm that's going on outside buffed my
stupidity.

Sent v2 with pr_warn_ratelimit(), it changes nothing in the logic.

>
>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>[]
>> @@ -2080,7 +2081,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
>>
>>  		/* select the active aggregator for the bond */
>>  		if (port) {
>> -			if (!port->slave) {
>> +			if (!port->slave && net_ratelimit()) {
>>  				pr_warn("%s: Warning: bond's first port is uninitialized\n",
>>  					bond->dev->name);
>>  				goto re_arm;
>
>Now the goto is ratelimited too.
>
>> @@ -2095,7 +2096,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
>>  	/* for each port run the state machines */
>>  	bond_for_each_slave_rcu(bond, slave, iter) {
>>  		port = &(SLAVE_AD_INFO(slave).port);
>> -		if (!port->slave) {
>> +		if (!port->slave && net_ratelimit()) {
>>  			pr_warn("%s: Warning: Found an uninitialized port\n",
>>  				bond->dev->name);
>>  			goto re_arm;
>
>here too.
>
>> @@ -2157,7 +2158,7 @@ static int bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave,
>>
>>  		port = &(SLAVE_AD_INFO(slave).port);
>>
>> -		if (!port->slave) {
>> +		if (!port->slave && net_ratelimit()) {
>>  			pr_warn("%s: Warning: port of slave %s is uninitialized\n",
>>  				slave->dev->name, slave->bond->dev->name);
>>  			return ret;
>
>And the return 3.
>
