From: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Tue, 18 Jan 2011 20:21:02 +0300
Message-ID: <4D35CBFE.5030406@yandex-team.ru>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death> <4D35060D.5080004@intel.com> <4D358A47.4020009@yandex-team.ru> <4D35C2D7.6090008@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from archeopterix.yandex.ru ([93.158.136.52]:49220 "EHLO
	archeopterix.yandex.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752800Ab1ARRVD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 12:21:03 -0500
In-Reply-To: <4D35C2D7.6090008@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/2011 07:41 PM, John Fastabend wrote:

>>
>> John, what is you opinion on such load balancing method in general,
>> without referring to particular use cases?
>>
>
> This seems reasonable to me, but I'll defer to Jay on this. As long a=
s the
> limitations are documented and it looks like they are this may be fin=
e.
>
> Mostly I was interested to know what led you down this path and why M=
PIO
> was not working as at least I expected it should. When I get some tim=
e I'll
> see if we can address at least some of these issues. Even so it seems=
 like
> this bonding mode may still be useful for some use cases perhaps even=
 none
> storage use cases.
>
>>

I was adressing several problems with my patch:
  - I was unable to consume whole bandwidth with multipath - with four=20
1Gbit "paths" it was slightly above 2Gbit/s
  - Link failures caused quite often disk failures, which led to Oracle=
=20
ASM rebalance, especially with versions below 11.
  - It is not always possible to autogenerate multipathd.conf with=20
human-readable device names because of iscsi session id and scsi device=
=20
bus/channel/etc mismatch(usually it differs by 1, but not necessarily),=
=20
with bonding solution I can just look into /dev/disk/by-path to find ou=
t=20
where physically is device, let's  say, /dev/sdab, located(it's just a=20
free bonus I've got, so to say:)) .



--=20
=D0=A1 =D1=83=D0=B2=D0=B0=D0=B6=D0=B5=D0=BD=D0=B8=D0=B5=D0=BC,
=D1=80=D1=83=D0=BA=D0=BE=D0=B2=D0=BE=D0=B4=D0=B8=D1=82=D0=B5=D0=BB=D1=8C=
 =D1=81=D0=BB=D1=83=D0=B6=D0=B1=D1=8B
=D1=8D=D0=BA=D1=81=D0=BF=D0=BB=D1=83=D0=B0=D1=82=D0=B0=D1=86=D0=B8=D0=B8=
 =D0=BA=D0=BE=D0=BC=D0=BC=D0=B5=D1=80=D1=87=D0=B5=D1=81=D0=BA=D0=B8=D1=85=
 =D0=B8 =D1=84=D0=B8=D0=BD=D0=B0=D0=BD=D1=81=D0=BE=D0=B2=D1=8B=D1=85 =D1=
=81=D0=B5=D1=80=D0=B2=D0=B8=D1=81=D0=BE=D0=B2
=D0=9E=D0=9E=D0=9E =D0=AF=D0=BD=D0=B4=D0=B5=D0=BA=D1=81

=D0=9E=D0=BB=D0=B5=D0=B3 =D0=AE=D1=85=D0=BD=D0=BE


