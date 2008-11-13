From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC PATCH 00/13] hardware time stamping + igb example	implementation
Date: Thu, 13 Nov 2008 07:29:25 +0100
Message-ID: <491BC945.9040902@cosmosbay.com>
References: <1226414697.17450.852.camel@ecld0pohly>	 <491AFF09.8070907@linux.intel.com> <1226507118.31699.91.camel@ecld0pohly> <491B23FE.9000105@hartkopp.net> <491B2D03.1090700@cosmosbay.com> <491B3B49.7070402@linux.intel.com> <491B42FF.3000407@cosmosbay.com> <491B4BE3.3010104@linux.intel.com> <491BC614.9050201@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick Ohly <patrick.ohly@intel.com>,
	Andi Kleen <ak@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:33709 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665AbYKMG3m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 01:29:42 -0500
In-Reply-To: <491BC614.9050201@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Hartkopp a =E9crit :
> Andi Kleen wrote:
>> Eric Dumazet wrote:
>>
>>> I threw a "crazy idea", that can be changed if necessary, say with =
a=20
>>> cookie
>>> that identifies the slot in NIC driver structure. O(1) lookup if=20
>>> really needed.
>>
>> I think "crazy" describes it well because it would be a lot of dubio=
us
>> and likely not performing well effort just to save 8 bytes.
>=20
> Patrick,
>=20
> one question about a new crazy idea:
>=20
> If we would tend to add new space in the skb, won't 4 bytes enough th=
en?
>=20
> A 32 bit value gives a nsec resolution of 4.294967296 seconds or +/-=20
> 2.147483648 seconds.
>=20
> If we make a 'full qualified' 64 bit sys-timestamp available anyway, =
the=20
> new 32 bit value could be used as an offest (or it could be given to =
the=20
> userspace directly) to calculate the hw timestamp within the=20
> sys-timestamp context, right?
>=20

If NIC is going to receive 100.000 frames per second as Andi mentioned =
earlier
my guess is you dont want to make sophisticated computation in NIC rx h=
andler,
but storing raw data delivered by NIC.

Then, later, for the happy few^Wmany applications that need to get hwst=
amp, perform
the computation if needed ?

I hope tcp stack wont need hwstamp before 2013 or so ;)

