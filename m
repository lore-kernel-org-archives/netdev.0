From: Arvid Brodin <arvid.brodin@xdin.com>
Subject: Re: [PATCH v3] net/hsr: Add support for the High-availability Seamless
 Redundancy protocol (HSRv0)
Date: Tue, 3 Sep 2013 17:30:58 +0200
Message-ID: <522600B2.8090507@xdin.com>
References: <521504E1.5060309@xdin.com> <20130830.155415.1756229438072680437.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <shemminger@vyatta.com>,
	<joe@perches.com>, <jboticario@gmail.com>,
	<balferreira@googlemail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:60701 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754298Ab3ICPkd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 11:40:33 -0400
In-Reply-To: <20130830.155415.1756229438072680437.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-08-30 21:54, David Miller wrote:
> From: Arvid Brodin <arvid.brodin@xdin.com>
> Date: Wed, 21 Aug 2013 20:20:17 +0200
>=20
>> This is a patch against net-next (2013-08-21).
>=20
> First of all, your email client corrupted the patch, chopping up long=
 lines
> and making whitespace changes to the content of the patch.  Please fi=
x this
> before resubmitting, and do so by first sending a test patch to yours=
elf
> and making sure you can apply the patch you receive in that email.  D=
o not
> use attachments to deal with this issue.

Sorry about that - I forgot to disable Format=3DFlowed... :(


>> +	if (dev->operstate !=3D transition) {
>> +		write_lock_bh(&dev_base_lock);
>> +		dev->operstate =3D transition;
>> +		write_unlock_bh(&dev_base_lock);
>> +		netdev_state_change(dev);
>> +	}
>=20
> This is racy.  And it appears that set_operstate() in net/core/rtnetl=
ink.c
> has the same bug, I guess that's what you used as a guide.
>=20
> Any "test and set" sequence must be guarded completely by the lock, i=
t
> doesn't make any sense to only guard the change of the value.

I never did understand the purpose of the locking done in set_operstate=
(). Will fix.

Also, Stephen Hemminger told me to use rtnl_mutex instead, but when I p=
ointed
to net/core/rtnetlink.c and asked if he was sure, I did not get a reply=
=2E This=20
function - __hsr_set_operstate() - is only called from a notifier_call =
function,=20
so rtnl_mutex is already held here. Do I even need additional locking?


(According to ULNI* pp 171 Stephen is right and net/core/rtnetlink.c is=
 wrong...)

* ULNI =3D Understanding Linux Network Internals

--=20
Arvid Brodin | Consultant (Linux)
XDIN AB | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden | xdin.com
