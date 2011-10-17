From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] iproute2: update CAN bitrate SJW help text
Date: Mon, 17 Oct 2011 19:02:05 +0200
Message-ID: <4E9C5F8D.1010909@hartkopp.net>
References: <4E9C4D29.7010302@hartkopp.net> <20111017085826.7a62ed11@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-can@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:56740 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753640Ab1JQRCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 13:02:07 -0400
In-Reply-To: <20111017085826.7a62ed11@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/11 17:58, Stephen Hemminger wrote:

> On Mon, 17 Oct 2011 17:43:37 +0200
> Oliver Hartkopp <socketcan@hartkopp.net> wrote:
> 
>> The ip-tool from iproute2 already supports to pass a user defined SJW
>> value for the in-kernel bittiming calculation. This patch updates the
>> help text accordingly.
>>
>> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
>>
>> ---
>>
>> diff --git a/ip/iplink_can.c b/ip/iplink_can.c
>> index c8af4bc..00e7d98 100644
>> --- a/ip/iplink_can.c
>> +++ b/ip/iplink_can.c
>> @@ -23,7 +23,8 @@ static void usage(void)
>>  {
>>  	fprintf(stderr,
>>  		"Usage: ip link set DEVICE type can\n"
>> -	        "\t[ bitrate BITRATE [ sample-point SAMPLE-POINT] ] | \n"
>> +		"\t[ bitrate BITRATE [ sample-point SAMPLE-POINT ] [ sjw SJW "
>> +		"] ] | \n"
>>  	        "\t[ tq TQ prop-seg PROP_SEG phase-seg1 PHASE-SEG1\n "
>>  		"\t  phase-seg2 PHASE-SEG2 [ sjw SJW ] ]\n"
>>  		"\n"
> 
> Please update man page as well.


Oops. The manpage has several issues regarding CAN support:

- this updated help text is _not_ part of the ip.8 man page at all

    It can only be accessed by 'ip link set <anynetdev> type can help'

Usage: ip link set DEVICE type can
	[ bitrate BITRATE [ sample-point SAMPLE-POINT] ] |
	[ tq TQ prop-seg PROP_SEG phase-seg1 PHASE-SEG1
 	  phase-seg2 PHASE-SEG2 [ sjw SJW ] ]

	[ loopback { on | off } ]
	[ listen-only { on | off } ]
	[ triple-sampling { on | off } ]
	[ one-shot { on | off } ]
	[ berr-reporting { on | off } ]

	[ restart-ms TIME-MS ]
	[ restart ]

	Where: BITRATE       := { 1..1000000 }
	       SAMPLE-POINT  := { 0.000..0.999 }
	       TQ            := { NUMBER }
	       PROP-SEG      := { 1..8 }
	       PHASE-SEG1    := { 1..8 }
	       PHASE-SEG2    := { 1..8 }
	       SJW           := { 1..4 }
	       RESTART-MS    := { 0 | NUMBER }

-> ip link set <anynetdev> "type TYPE" is not documented in help text & man
page anywhere

- VCAN and CAN interfaces are mixed in the man page

    You can not create real CAN interfaces, only virtual ones.

Looks like i tapped into a bigger problem here :-(

Maybe it's the best to apply this help text update first and then to try to
rework the ip.8 man page according to the latest version.

Setting the CAN bittiming & controller setting does not seem to fit into the
'ip link' section of the man page. Do you have an idea how to do that in a
'nice' way?

Regards,
Oliver
