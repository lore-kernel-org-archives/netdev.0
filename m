From: Pawel Sokolowski <falcon@muflon.linux.pl>
Subject: Re: 2.6.4-rc1 + hp100 EISA, not working
Date: Thu, 4 Mar 2004 06:04:24 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403040550150.25624@don.falconne.eu.org>
References: <Pine.LNX.4.58.0402292149230.25624@don.falconne.eu.org>
 <wrpk724yicq.fsf@hina.wild-wind.fr.eu.org> <20040303122541.4dbcf0fc@dell_ss3.pdx.osdl.net>
Reply-To: pawel.sokolowski@muflon.linux.pl
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-2
Content-Transfer-Encoding: quoted-printable
Cc: mzyngier@freesurf.fr, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040303122541.4dbcf0fc@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've seen things you people wouldn't believe. You writing:
>> Pawel> On 2.6.3 it just Oopsed and didn't work. On 2.6.4-rc1 it does
>> Pawel> not oops but it doesn't work (neither as module nor as build in=
 kernel).
>> Note that hp100 in 2.6.4-rc1 is still broken wrt EISA probing, since
>> it lacks the terminating entry in the EISA ID list. This one-liner
>> should take care of random crashes that are often reported to LKML :
>>
>> =3D=3D=3D=3D=3D drivers/net/hp100.c 1.24 vs edited =3D=3D=3D=3D=3D
>> --- 1.24/drivers/net/hp100.c	Wed Feb 18 13:39:41 2004
>> +++ edited/drivers/net/hp100.c	Mon Mar  1 11:18:00 2004
>> @@ -201,6 +201,7 @@
>>  	{ "HWP1990" }, /* HP J2577 */
>>  	{ "CPX0301" }, /* ReadyLink ENET100-VG4 */
>>  	{ "CPX0401" }, /* FreedomLine 100/VG */
>> +	{ "" }	       /* Mandatory final entry ! */
>>  };
>>  MODULE_DEVICE_TABLE(eisa, hp100_eisa_tbl);
>>  #endif
>
>It could be that there is a typo in the hp100 eisa device list, the foll=
owing
>
>--- linux-2.6/drivers/eisa/eisa-bus.c	2004-01-23 09:38:19.000000000 -080=
0
>+++ tcp-2.6/drivers/eisa/eisa-bus.c	2004-03-03 12:23:53.604252800 -0800
[...]
>+	printk(KERN_DEBUG "eisa_bus_match dev sig=3D'%s' state=3D0x%x eids=3D%=
s\n",
>+	       edev->id.sig, edev->state, eids ? eids->sig : "<null>");

With eisa_bus.enable_dev=3D2 I'm getting:

eisa_bus_match dev sig=3D'HWPC061' state=3D0x1 eids=3DHWPF180
eisa_bus_match dev sig=3D'HWP1940' state=3D0x3 eids=3DHWPF180

without:

eisa_bus_match dev sig=3D'HWPC061' state=3D0x1 eids=3DHWPF180
eisa_bus_match dev sig=3D'HWP1940' state=3D0x0 eids=3DHWPF180

when modprobing hp100.

--=20
  ,d$$$$$P.d$$b     d$P  ,gd$$$$$,gd$$$$g. ,$$$b._$$P               RLU #=
172534
  ggggggggggggg.   ggs  ,gg     ,gg    ,gg ggp,ggggg           Pawe=B3 So=
ko=B3owski
 d$P""""'""""Y$$. d$P   d$P     d$P   ,d$Pd$P `Y$$P      falcon@muflon.li=
nux.pl
d$P           Y$$d$$$$$P`Y$$$$$'`Y$$$$$P'd$P   d$P    Replicant (M) Des: =
Falcon
