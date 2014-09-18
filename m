From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCHv6 net-next 1/3] sunvnet: upgrade to VIO protocol version
 1.6
Date: Thu, 18 Sep 2014 09:21:31 -0400
Message-ID: <541ADC5B.2080702@oracle.com>
References: <541A2316.5010603@oracle.com> <F34B8038-D189-4DD7-BF98-26CC4BD11990@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30978 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753540AbaIRNVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 09:21:35 -0400
In-Reply-To: <F34B8038-D189-4DD7-BF98-26CC4BD11990@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/18/2014 12:23 AM, Raghuram Kothakota wrote:

>>
>> +	/* v1.6 and higher, ACK with desired, supported mode, or NACK */
>> +	if (vio_version_after_eq(vio, 1, 6)) {
>> +		if (!(pkt->options & VIO_TX_DRING))
>> +			goto send_nack;
>> +		pkt->options = VIO_TX_DRING;
>> +	}
>> +
> 
> 
> I forget to send this comment in my previous email. The above function is
> common to all clients, that includes vdisk.  The vdisk today doesn't use any
> version number above 1.2 or 1.3, so it probably won't impact it, but  this
> special handling doesn't seem to belong in the common code.

Yes, this is updating the VIO protocol, which is used by both sunvnet and sunvdc.
If the vdisk uses a newer protocol version, it will need to do exactly what this
code does (and it already will, because this code is there).

Any protocol version differences in the vdisk-specific code will need to be part
of a vdisk version upgrade patch. The particular VIO version that is negotiated
is specified in the individual drivers and my patches update that for sunvnet only.
The sunvdc code is still negotiating and using 1.0 in the net-next kernel, so
none of these version checks change anything for the sunvdc driver.

							+-DLS
