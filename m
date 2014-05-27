From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next 8/8] net: cdc_ncm: document the sysfs API
Date: Tue, 27 May 2014 13:07:29 +0200
Message-ID: <87bnujiioe.fsf@nemi.mork.no>
References: <1401101625-12342-1-git-send-email-bjorn@mork.no>
	<1401101625-12342-9-git-send-email-bjorn@mork.no>
	<20140527104043.3456.qmail@stuge.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Lars Melin <larsm17@gmail.com>,
	Greg Suarez <gsuarez@smithmicro.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:60777 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751655AbaE0LHp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 07:07:45 -0400
In-Reply-To: <20140527104043.3456.qmail@stuge.se> (Peter Stuge's message of
	"Tue, 27 May 2014 12:40:43 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Stuge <peter@stuge.se> writes:

> Bj=C3=B8rn Mork wrote:
>> +++ b/Documentation/ABI/testing/sysfs-class-net-cdc_ncm
>> @@ -0,0 +1,143 @@
>> +What:		/sys/class/net/<iface>/cdc_ncm/min_tx_pkt
>> +Date:		May 2014
>> +KernelVersion:	3.16
>> +Contact:	Bj=C3=B8rn Mork <bjorn@mork.no>
>> +Description:
>> +		The driver will pad frames longer than this to tx_max,
>                                            ^^^^^^
> longer or shorter?

longer.  If it is shorter then it is sent as-is.  I guess this setting
could use a bit more explanation here.


>
>> +What:		/sys/class/net/<iface>/cdc_ncm/rx_max
>> +Date:		May 2014
>> +KernelVersion:	3.16
>> +Contact:	Bj=C3=B8rn Mork <bjorn@mork.no>
>> +Description:
>> +		The maximum NCM Transfer Block (NTB) size for RX.
>> +		Cannot exceed the maximum value supported by the
>> +		device. Must allow at least one max sized datagram
>> +		plus headers.
>> +
>> +		The actual limits are device dependent.  See
>> +		dwNtbInMaxSize.
>> +
>> +		Note: Some devices will silently ignore changes to
>> +		this value, resulting in oversized NTBs and
>> +		corresponding framing errors.
>
> That behavior makes the setting only so-so useful. Could the driver
> know which devices do this, or is it inconsistent even across
> individual devices which are otherwise indistinguishable?

I have no idea, and I don't know how to find out.  I've observed the
failure on one of my MBIM modems.  That's all I know.

I believe the setting still is useful for all spec compliant devices,
and even most of the others.  The firmware bug does make it difficult t=
o
do any automagic tuning.  But it's not impossible.  The tuning
application can do a bit of probing and looking at the frame error
counter.

>> +What:		/sys/class/net/<iface>/cdc_ncm/tx_timer_usecs
>> +Date:		May 2014
>> +KernelVersion:	3.16
>> +Contact:	Bj=C3=B8rn Mork <bjorn@mork.no>
>> +Description:
>> +		Datagram aggregation timeout in =C2=B5s. The driver will
>> +		wait up to 3 times this timeout for more datagrams to
>> +		aggregate before transmitting a NTB frame.
>                                               ^
> "an NTB frame" might be better since N sounds like "enn".


OK

>> +
>> +		Valid range: 5 to 4000000
>> +
>> +		Set to 0 to disable aggregation.
>> +
>> +The following read only attributes all represent fields of the
>
> read-only?

OK


Thanks for reviewing this.



Bj=C3=B8rn
