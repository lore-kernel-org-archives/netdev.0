From: Wang Sheng-Hui <shhuiw@gmail.com>
Subject: Re: [PATCH] bonding: use pre-defined macro in bond_mode_name instead
 of magic number 0
Date: Wed, 24 Jul 2013 20:38:02 +0800
Message-ID: <51EFCAAA.4050402@gmail.com>
References: <51EF79E6.9060309@gmail.com> <1374649819.18818.5.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:43731 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069Ab3GXMiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 08:38:15 -0400
Received: by mail-pa0-f53.google.com with SMTP id lb1so602119pab.40
        for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 05:38:14 -0700 (PDT)
In-Reply-To: <1374649819.18818.5.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013=E5=B9=B407=E6=9C=8824=E6=97=A5 15:10, Joe Perches wrote:
> On Wed, 2013-07-24 at 14:53 +0800, Wang Sheng-Hui wrote:
>> We have BOND_MODE_ROUNDROBIN pre-defined as 0, and it's the lowest m=
ode number.
>> Use it to check the arg lower bound instead of magic number 0 in bon=
d_mode_name.
> []
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
> []
>> @@ -273,7 +273,7 @@ const char *bond_mode_name(int mode)
>>    		[BOND_MODE_ALB] =3D "adaptive load balancing",
>>    	};
>>
>> -	if (mode < 0 || mode > BOND_MODE_ALB)
>> +	if (mode < BOND_MODE_ROUNDROBIN || mode > BOND_MODE_ALB)
>>    		return "unknown";
>>
>>    	return names[mode];
>
> Probably be simpler, less confusing, and more normal style
> to use a switch case.
>
> 	switch (mode) {
> 	case BOND_MODE_ROUNDROBIN:
> 		return "load balancing (round-robin)";
> 	case BOND_MODE_ACTIVEBACKUP:
> 		return "fault-tolerance (active-backup)";
> 	case BOND_MODE_XOR:
> 		return "load balancing (xor)";
> 	case BOND_MODE_BROADCAST;
> 		return "fault-tolerance (broadcast)";
> 	case BOND_MODE_8023AD:
> 		return "IEEE 802.3ad Dynamic link aggregation";
> 	case BOND_MODE_TLB:
> 		return "transmit load balancing";
> 	case BOND_MODE_ALB:
> 		return "adaptive load balancing";
> 	default:
> 		return "unknown";
> 	}
>
>

Regenerated the patch on Joe's advice. Please check it.  Thanks,


[PATCH] bonding: use switch case to make bond_mode_name more clear

We have predefined the mode macros, and should avoid the
magic number 0 in the old version. Also, use a switch case
would be simpler, less confusing, and more normal style.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
  drivers/net/bonding/bond_main.c |   30 +++++++++++++++++-------------
  1 file changed, 17 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 07f257d4..69bfb4c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -263,20 +263,24 @@ static void bond_uninit(struct net_device *bond_d=
ev);

  const char *bond_mode_name(int mode)
  {
-	static const char *names[] =3D {
-		[BOND_MODE_ROUNDROBIN] =3D "load balancing (round-robin)",
-		[BOND_MODE_ACTIVEBACKUP] =3D "fault-tolerance (active-backup)",
-		[BOND_MODE_XOR] =3D "load balancing (xor)",
-		[BOND_MODE_BROADCAST] =3D "fault-tolerance (broadcast)",
-		[BOND_MODE_8023AD] =3D "IEEE 802.3ad Dynamic link aggregation",
-		[BOND_MODE_TLB] =3D "transmit load balancing",
-		[BOND_MODE_ALB] =3D "adaptive load balancing",
-	};
-
-	if (mode < 0 || mode > BOND_MODE_ALB)
+	switch (mode) {
+	case BOND_MODE_ROUNDROBIN:
+		return "load balancing (round-robin)";
+	case BOND_MODE_ACTIVEBACKUP:
+		return "fault-tolerance (active-backup)";
+	case BOND_MODE_XOR:
+		return "load balancing (xor)";
+	case BOND_MODE_BROADCAST:
+		return "fault-tolerance (broadcast)";
+	case BOND_MODE_8023AD:
+		return "IEEE 802.3ad Dynamic link aggregation";
+	case BOND_MODE_TLB:
+		return "transmit load balancing";
+	case BOND_MODE_ALB:
+		return "adaptive load balancing";
+	default:
  		return "unknown";
-
-	return names[mode];
+	}
  }

  /*---------------------------------- VLAN ---------------------------=
--------*/
--=20
1.7.10.4
