From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH 4/4] Staging: Octeon:  Free transmit SKBs in a timely
 manner.
Date: Mon, 15 Feb 2010 12:41:03 -0800
Message-ID: <4B79B15F.7030506@caviumnetworks.com>
References: <4B79AAA6.60005@caviumnetworks.com>	 <1266264799-3510-4-git-send-email-ddaney@caviumnetworks.com> <1266265673.2859.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:1389 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751657Ab0BOUlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 15:41:08 -0500
In-Reply-To: <1266265673.2859.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/15/2010 12:27 PM, Eric Dumazet wrote:
> Le lundi 15 f=C3=A9vrier 2010 =C3=A0 12:13 -0800, David Daney a =C3=A9=
crit :
>> If we wait for the once-per-second cleanup to free transmit SKBs,
>> sockets with small transmit buffer sizes might spend most of their
>> time blocked waiting for the cleanup.
>>
>> Normally we do a cleanup for each transmitted packet.  We add a
>> watchdog type timer so that we also schedule a timeout for 150uS aft=
er
>> a packet is transmitted.  The watchdog is reset for each transmitted
>> packet, so for high packet rates, it never expires.  At these high
>> rates, the cleanups are done for each packet so the extra watchdog
>> initiated cleanups are not needed.
>
> s/needed/fired/
>

or perhaps s/are not needed/are neither needed nor fired/

> Hmm, but re-arming a timer for each transmited packet must have a cos=
t ?
>

The cost is fairly low (less than 10 processor clock cycles).  We didn'=
t=20
add this for amusement, people actually do things like only send UDP=20
packets from userspace.  Since we can fill the transmit queue faster=20
than it is emptied, the socket transmit buffer is quickly consumed.  If=
=20
we don't free the SKBs in short order, the transmitting process get to=20
take a long sleep (until our previous once per second clean up task was=
=20
run).

>>
>> Signed-off-by: David Daney<ddaney@caviumnetworks.com>
>
> Is there any particular reason periodic is spelled preiodic ?

Ha!  No good reason.  I will correct the spelling.

Thanks,
David Daney


>
>> ---
>>   }
>>
>> -static void cvm_oct_tx_clean_worker(struct work_struct *work)
>> +static void cvm_oct_preiodic_worker(struct work_struct *work)
>>   {
>
>
>
>> -			INIT_DELAYED_WORK(&priv->tx_clean_work,
>> -					  cvm_oct_tx_clean_worker);
>> -
>> +			INIT_DELAYED_WORK(&priv->port_periodic_work,
>> +					  cvm_oct_preiodic_worker);
>
>
>
>

