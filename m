From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: Re: [PATCH net-next 3/5] bonding: fix incorrect lacp mux state when
 agg not active
Date: Mon, 19 Jan 2015 15:50:48 -0500
Message-ID: <54BD6E28.8020705@cumulusnetworks.com>
References: <1421423848-414-1-git-send-email-jtoppins@cumulusnetworks.com> <1421423848-414-4-git-send-email-jtoppins@cumulusnetworks.com> <54BD5A53.8050609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:39843 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484AbbASUuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 15:50:51 -0500
Received: by mail-qc0-f175.google.com with SMTP id c9so5400564qcz.6
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 12:50:50 -0800 (PST)
In-Reply-To: <54BD5A53.8050609@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/19/15 2:26 PM, Nikolay Aleksandrov wrote:
>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>> index e9b706f..52a8772 100644
>> --- a/drivers/net/bonding/bond_3ad.c
>> +++ b/drivers/net/bonding/bond_3ad.c
>> @@ -471,10 +471,13 @@ static void __record_pdu(struct lacpdu *lacpdu, struct port *port)
>>   		 * and the port is matched
>>   		 */
>>   		if ((port->sm_vars & AD_PORT_MATCHED)
>> -		    && (lacpdu->actor_state & AD_STATE_SYNCHRONIZATION))
>> +			&& (lacpdu->actor_state & AD_STATE_SYNCHRONIZATION)) {
> In net/ it's preferred to have the logical operators at the end of the
> previous line. It'd be nice if we start fixing these in bond_3ad.c since
> they're being touched by the patch anyhow.

Ack, I prefer at the end too. Question, would it be acceptable to do the 
cleanup of the entire bond_3ad.c code in a separate patch? That way the 
fix vs. cleanup is clear.


>>   		case AD_MUX_COLLECTING_DISTRIBUTING:
>>   			if (!(port->sm_vars & AD_PORT_SELECTED) ||
>>   			    (port->sm_vars & AD_PORT_STANDBY) ||
>> -			    !(port->partner_oper.port_state & AD_STATE_SYNCHRONIZATION)) {
>> +			    !(port->partner_oper.port_state &
>> +				AD_STATE_SYNCHRONIZATION) ||
>> +			    !(port->actor_oper_port_state &
>> +				AD_STATE_SYNCHRONIZATION)) {
> IMO this one looks a bit confusing when broken up like that.

Ack, it seems in this case making checkpatch.pl happy should be secondary.
