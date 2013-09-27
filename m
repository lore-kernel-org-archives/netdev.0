From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 2/9] bonding: remove __get_first_port()
Date: Fri, 27 Sep 2013 17:05:17 +0200
Message-ID: <20130927150517.GA833@redhat.com>
References: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
 <1380291125-5671-3-git-send-email-vfalico@redhat.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7365@saturn3.aculab.com>
 <20130927145825.GA14139@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, nikolay@redhat.com,
	bhutchings@solarflare.com, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41657 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752643Ab3I0PHT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 11:07:19 -0400
Content-Disposition: inline
In-Reply-To: <20130927145825.GA14139@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 27, 2013 at 04:58:25PM +0200, Veaceslav Falico wrote:
>On Fri, Sep 27, 2013 at 03:50:12PM +0100, David Laight wrote:
>>>@@ -2104,8 +2091,11 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
>>>
>>> 	// check if agg_select_timer timer after initialize is timed out
>>> 	if (BOND_AD_INFO(bond).agg_select_timer && !(--BOND_AD_INFO(bond).agg_select_timer)) {
>>>+		slave = bond_first_slave(bond);
>>>+		port = slave ? &(SLAVE_AD_INFO(slave).port) : NULL;
>>>+
>>> 		// select the active aggregator for the bond
>>>-		if ((port = __get_first_port(bond))) {
>>>+		if (port) {
>>> 			if (!port->slave) {
>>> 				pr_warning("%s: Warning: bond's first port is uninitialized\n",
>>> 					   bond->dev->name);
>>>--
>>
>>Looks like that could be:
>>		slave = bond_first_slave(bond);
>>		if (slave) {
>>			port = SLAVE_AD_INFO(slave).port;
>>and I assume 'slave == port->slave' so there is no need for the latter check?
>
>I've also fallen to this trap at first - slave->port can (virtually) be
>NULL, and this way we'll panic on "if (!port->slave)".

Err, forgot to address the 'slave == port->slave' - yes, virtually it
should be - if it's initialized (and, it should be) - however, as I've
stated in the cover letter - there are *tons* of cleanups/optimizations of
these kind that might be done here - and not to mix cleanups/optimizations
with the thing that these patches should do (remove bond_next_slave) - I've
decided to leave it as close to the original as possible.

>
>>
>>	David
>>
>>
>>
