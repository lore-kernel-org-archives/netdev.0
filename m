From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/5] bonding: keep bond interface carrier off
 until at least one active member
Date: Mon, 19 Jan 2015 15:54:16 -0500
Message-ID: <54BD6EF8.2030206@cumulusnetworks.com>
References: <1421423848-414-1-git-send-email-jtoppins@cumulusnetworks.com> <1421423848-414-2-git-send-email-jtoppins@cumulusnetworks.com> <54BD5ABE.9040806@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:43464 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbbASUyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 15:54:22 -0500
Received: by mail-qg0-f44.google.com with SMTP id l89so17960016qgf.3
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 12:54:20 -0800 (PST)
In-Reply-To: <54BD5ABE.9040806@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/19/15 2:27 PM, Nikolay Aleksandrov wrote:
> On 01/16/2015 04:57 PM, Jonathan Toppins wrote:
>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>> index 8baa87d..e9b706f 100644
>> --- a/drivers/net/bonding/bond_3ad.c
>> +++ b/drivers/net/bonding/bond_3ad.c
>> @@ -189,6 +189,7 @@ static inline int __agg_has_partner(struct aggregator *agg)
>>   static inline void __disable_port(struct port *port)
>>   {
>>   	bond_set_slave_inactive_flags(port->slave, BOND_SLAVE_NOTIFY_LATER);
>> +	bond_3ad_set_carrier(port->slave->bond);
>>   }
>>
>>   /**
>> @@ -199,8 +200,10 @@ static inline void __enable_port(struct port *port)
>>   {
>>   	struct slave *slave = port->slave;
>>
>> -	if ((slave->link == BOND_LINK_UP) && bond_slave_is_up(slave))
>> +	if ((slave->link == BOND_LINK_UP) && bond_slave_is_up(slave)) {
> While at it please remove the extra ( ) around slave->link == BOND_LINK_UP.
>
Ack.
