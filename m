From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH] r8169: fix random mdio_write failures
Date: Wed, 9 Jun 2010 10:47:01 +0800
Message-ID: <BD599B881C1D407DA7BC93A9244650B0@realtek.com.tw>
References: <4C0A1736.9030209@iki.fi>     <1275733273-28321-1-git-send-email-timo.teras@iki.fi>     <20100605124103.GA3213@electric-eye.fr.zoreil.com>     <4C31B2E3BE2B481DB749C669DFE23645@realtek.com.tw>     <20100607215115.GA6583@electric-eye.fr.zoreil.com> <4C0DDDCC.6010500@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: =?iso-8859-1?Q?'Timo_Ter=E4s'?= <timo.teras@iki.fi>,
	'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtitmf2.realtek.com ([60.250.210.236]:1753 "EHLO
	mf2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810Ab0FICrF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 22:47:05 -0400
In-Reply-To: <4C0DDDCC.6010500@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think the major point is that it needs a delay (20 us) after both rea=
d and
write completed indiacation before next command.
It needs almost 100 us for the indication to be completed, so our engin=
eer
suggests us to check the indication per 100 us.
However, it is  ok to reduce the timer from 100 us to 25 us for checkin=
g .
=20
Best Regards,
Hayes


-----Original Message-----
=46rom: Timo Ter=E4s [mailto:timo.teras@gmail.com] On Behalf Of Timo Te=
ras
Sent: Tuesday, June 08, 2010 2:06 PM
To: Francois Romieu
Cc: Hayeswang; netdev@vger.kernel.org; davem@davemloft.net
Subject: Re: [PATCH] r8169: fix random mdio_write failures

On 06/08/2010 12:51 AM, Francois Romieu wrote:
> hayeswang <hayeswang@realtek.com> :
>> Our hardware engineer suggests that check the completed indication=20
>> per 100 micro seconds. And it needs 20 micro seconds delay after the=
=20
>> completed indication for the next command.
>=20
> Should we do the same for mdio_read as well (100 us per iteration + a=
n=20
> extra 20 us) ?

Well, doing 100us per iteration will increase the latency that the code
notices "write complete" which slows down things. It'll also slightly
decrease bus traffic which is good. But I'd be just fine with 25us per
iteration. It sounds unlikely that polling the status register would sl=
ow
down the actual write operation (if that is the case then 100us would b=
e
desirable).

Changing my 25us to 20us would good. The original 25us was just a guess=
=2E
The comment should be probably also updated that those delays are from
realtek hw specs then.

Would you like me to send a patch?

- Timo




------Please consider the environment before printing this e-mail.=20



