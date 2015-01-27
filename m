From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net-next v2 4/5] bonding: fix LACP PDU not sent on slave port sometimes
Date: Mon, 26 Jan 2015 16:45:38 -0800
Message-ID: <21753.1422319538@famine>
References: <1422253021-3798-1-git-send-email-jtoppins@cumulusnetworks.com> <1422253021-3798-5-git-send-email-jtoppins@cumulusnetworks.com> <54C62D5E.9030200@cogentembedded.com>
Cc: Jonathan Toppins <jtoppins@cumulusnetworks.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	Satish Ashok <sashok@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:60137 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757592AbbA0Apn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 19:45:43 -0500
In-reply-to: <54C62D5E.9030200@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:

>Hello.
>
>On 1/26/2015 9:17 AM, Jonathan Toppins wrote:
>
>> From: Satish Ashok <sashok@cumulusnetworks.com>
>
>> When a slave is added to a bond and it is not in full duplex mode,
>> AD_PORT_LACP_ENABLED flag is cleared, due to this LACP PDU is not sent
>
>   s/is not/not being/.

	I don't have an issue with the original text, or the updating of
nearby debug messages to include the device name (below).  Worst case
would be to respin and add a mention of this to the commit message.

	-J

Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>


>> on slave. When the duplex is changed to full, the flag needs to be set
>> to send LACP PDU.
>
>> Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
>> Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>
>> Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
>> Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
>> ---
>>   drivers/net/bonding/bond_3ad.c |   11 ++++++++---
>>   1 file changed, 8 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>> index e3c96b2..cfc4a9c 100644
>> --- a/drivers/net/bonding/bond_3ad.c
>> +++ b/drivers/net/bonding/bond_3ad.c
>> @@ -2219,8 +2219,10 @@ static int bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave,
>>   		switch (lacpdu->subtype) {
>>   		case AD_TYPE_LACPDU:
>>   			ret = RX_HANDLER_CONSUMED;
>> -			netdev_dbg(slave->bond->dev, "Received LACPDU on port %d\n",
>> -				   port->actor_port_number);
>> +			netdev_dbg(slave->bond->dev,
>> +				   "Received LACPDU on port %d slave %s\n",
>> +				   port->actor_port_number,
>> +				   slave->dev->name);
>>   			/* Protect against concurrent state machines */
>>   			spin_lock(&slave->bond->mode_lock);
>>   			ad_rx_machine(lacpdu, port);
>> @@ -2312,7 +2314,10 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave)
>>   	port->actor_admin_port_key &= ~AD_DUPLEX_KEY_MASKS;
>>   	port->actor_oper_port_key = port->actor_admin_port_key |=
>>   		__get_duplex(port);
>> -	netdev_dbg(slave->bond->dev, "Port %d changed duplex\n", port->actor_port_number);
>> +	netdev_dbg(slave->bond->dev, "Port %d slave %s changed duplex\n",
>> +		   port->actor_port_number, slave->dev->name);
>
>   The above 2 changes seem unrelated/undocumented in the change log...
>
>[...]
>
>WBR, Sergei
>

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
