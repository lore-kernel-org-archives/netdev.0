From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH net-next 6/8] net: gre: Implement LCO for GRE over IPv4
Date: Wed, 20 Jan 2016 23:34:03 +0000
Message-ID: <DA2674DE-A4F4-4375-9E22-121E76C95830@intel.com>
References: <56901197.8040808@solarflare.com>
 <56901235.1010800@solarflare.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCC1D7E@AcuExch.aculab.com>
 <5693AC59.4080702@solarflare.com>
 <CAKgT0UdSRi-iwZpBWrezg=-fFcVTFSd=2FOOye_oZr2oNCNJAw@mail.gmail.com>
 <8BD201BE-E272-4BA7-ABB4-8FDCE139495D@intel.com>
 <CAKgT0Ufpj2DpaLPOzU5hyFATpjN=jT9ziJCpmSMo1QkefAcAKQ@mail.gmail.com>
 <CALx6S362HV4epG885kp9B7xAd6oHdVZUQMzXjrd=zdyt7PzJ4Q@mail.gmail.com>
 <CAKgT0UeAsAUWSdn+tcE0gYV-WnDukUfxBkHyCwon3ChkxFmVsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_6C043DA8-6CEC-43B2-974B-A49660154B69";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Tom Herbert <tom@herbertland.com>,
	Edward Cree <ecree@solarflare.com>,
	David Laight <David.Laight@aculab.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:39435 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754035AbcATXeG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2016 18:34:06 -0500
In-Reply-To: <CAKgT0UeAsAUWSdn+tcE0gYV-WnDukUfxBkHyCwon3ChkxFmVsA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_6C043DA8-6CEC-43B2-974B-A49660154B69
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii;
	delsp=yes;
	format=flowed

Alexander Duyck <alexander.duyck@gmail.com> wrote:

> There isn't any need to add such an indication, nor do we need to
> start bitflipping the return value from csum_fold in all cases.  I
> think there was just some confusion about UDP checksums vs GRE or TCP
> checksums.

Yeah. I think I finally got there. The naive software methods will never  
generate a true 0 unless everything was zero. Real one's complement  
machines did addition in terms of subtraction so that 1 + -1 would never  
produce a -0, only a normal 0. Of course a simple adder would produce a -0,  
making it impossible to get back to a normal 0.

> I'd say we are better off keeping this simple.  The original patch
> just needs to drop the check for the resultant checksum being 0 since
> that is not needed for GRE.

I'm all in favor of simple. I had just started to worry about a possible  
change in behavior that might have interoperability problems with some  
implementations. I wonder if any implementation ever did the addition by  
subtraction, but also failed to make 0 compare equal to -0? I guess if they  
knew enough to do the former, they should not have blown the latter.
--Apple-Mail=_6C043DA8-6CEC-43B2-974B-A49660154B69--
