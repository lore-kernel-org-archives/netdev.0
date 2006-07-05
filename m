From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [e1000]: flow control on by default - good idea really?
Date: Wed, 5 Jul 2006 22:45:08 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0607052241230.12611@bizon.gios.gov.pl>
References: <1152033116.5276.22.camel@jzny2> <1152040839.5276.25.camel@jzny2>
 <20060705.112237.41652489.davem@davemloft.net> <44AC05A8.9030503@intel.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-129626438-1152132308=:12611"
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	Robert.Olsson@data.slu.se, john.ronciak@intel.com,
	greearb@candelatech.com, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:61583 "EHLO
	bizon.gios.gov.pl") by vger.kernel.org with ESMTP id S964820AbWGEUpi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 16:45:38 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <44AC05A8.9030503@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-129626438-1152132308=:12611
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Wed, 5 Jul 2006, Auke Kok wrote:

> David Miller wrote:
>> From: jamal <hadi@cyberus.ca>
>> Date: Tue, 04 Jul 2006 15:20:39 -0400
>>=20
>>> BTW, As an addendum this default behavior changed around 2.6.16 it
>>> seems.
>>=20
>> Flow control has been on by default in the tg3 driver since the
>> beginning, maybe e1000 only recently started to behave that way
>> but it's the right thing to do IMHO.
>
> As said earlier, e1000 always honors the EEPROM setting for this, which h=
as=20
> been _on_ by default for all cards (AFAIK, that is).

I'm not sure:

root@r1:~# mii-tool -v eth0
eth0: negotiated 100baseTx-FD, link ok
   product info: vendor 00:aa:00, model 56 rev 0
   basic mode:   autonegotiation enabled
   basic status: autonegotiation complete, link ok
   capabilities: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
   advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
   link partner: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-contr=
ol

root@r1:~# ethtool -d eth0|grep flow
       Receive flow control:              disabled
       Transmit flow control:             disabled

root@r1:~# uname -r
2.6.14.3

root@r2:~# mii-tool -v eth0
eth0: negotiated 100baseTx-FD flow-control, link ok
   product info: vendor 00:aa:00, model 56 rev 0
   basic mode:   autonegotiation enabled
   basic status: autonegotiation complete, link ok
   capabilities: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
   advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-contr=
ol
   link partner: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-contr=
ol

root@r2:~# ethtool -d eth0|grep flow
       Receive flow control:              enabled
       Transmit flow control:             enabled

root@r2:~# uname -r
2.6.16.19

This is exactly the same hardware, only kernel was recently upgraded on=20
the r2.

Best regards,


 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-129626438-1152132308=:12611--
