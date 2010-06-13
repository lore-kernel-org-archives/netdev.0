From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: mpd client timeouts (bisected) 2.6.35-rc3
Date: Sun, 13 Jun 2010 01:05:27 -0700
Message-ID: <4C149147.3080808@intel.com>
References: <20100612102802.GA1782@arch.tripp.de> <20100612.145835.123986343.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "markus@trippelsdorf.de" <markus@trippelsdorf.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:23922 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751704Ab0FMIF3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Jun 2010 04:05:29 -0400
In-Reply-To: <20100612.145835.123986343.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Markus Trippelsdorf <markus@trippelsdorf.de>
> Date: Sat, 12 Jun 2010 12:28:02 +0200
>=20
>> Commit 597a264b1a9c7e36d1728f677c66c5c1f7e3b837:
>> =BBnet: deliver skbs on inactive slaves to exact matches=AB
>>
>> causes large timeouts when mpd clients try to connect to a locally
>> running mpd (music player demon) on my machine. This makes it=20
>> impossible to control mpd.
>>
>> I bisected this down to the commit mentioned above.
>> Reverting the commit from 2.6.35-rc3 also solves the problem.
>=20
> John, find an easy and fast way to fix this or else I am
> going to revert.
>=20
> Thanks.

Looks like skbs are hitting loopback_xmit() with deliver_no_wcard set. =
 Then in=20
the receive path these skbs are only delivered to exact matches.  Not s=
ure why=20
this bit is set here, I'll track this down first thing tomorrow.

Thanks,
John.
