From: Jens Laas <jens.laas@data.slu.se>
Subject: Re: 2.6.6 e1000 NETDEV WATCHDOG: eth0: transmit timed out
Date: Fri, 18 Jun 2004 10:04:07 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.60.0406180953240.1089@jlaas2.data.slu.se>
References: <40CDD68C.8070509@dgreaves.com> <20040615155111.26d6b809@dell_ss3.pdx.osdl.net>
 <40D0280B.2030308@dgreaves.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-701340058-1087545847=:1089"
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Greaves <david@dgreaves.com>
In-Reply-To: <40D0280B.2030308@dgreaves.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-701340058-1087545847=:1089
Content-Type: TEXT/PLAIN; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by mail1.slu.se id i5I8478e022753

(04.06.16 kl.11:59) David Greaves skrev f=F6ljande till Stephen Hemminger=
:

We have seen the same symptoms. (2.6.x + e1000)

Our system is an SMP system. That might be whats triggering the problem.
Is your system UP or SMP ?
(Next reboot we will test running on only one CPU).

We have tried with and without NAPI, both exhibit the same problem.
We have tried different versions of e1000 without luck.
We have tried with 100Mb and gigabit switches.

Make sure that flowcontrol is disabled on your switch (if it has it=20
implemented).

> Stephen Hemminger wrote:
>
>> How big is the transmit ring. Setting a bigger transmit ring fixed my=20
>> problem
>> 	modprobe e1000 TxDescriptors=3D1024

I wouldnt call that a fix, more like a workaround. It should work
  regardless of ringsize.


>>=20
>> Also, there are lots of flavors of this chipset and board.  One machin=
e
>> I was using had the IBM rebranded version and it would only do PCI33 n=
ot=20
>> PCI66.
>>=20
>>=20
> Thanks for replying Stephen - it's really frustrating :)
>
> I did try TxDescriptors and various (most) other parameters (below are =
the=20
> actual parameter variations I tried - just cut from a 'history' for inf=
o).
>
> After each one i downed the link and modprobe -r the driver.
> I then ran a large file scp (quicker id+recovery than nfs hanging when =
the=20
> link died)
>
> I invariably got an eth0 timed out after a few seconds - some variation=
 but=20
> IIRC no more than 20% - ie 8-10Mb of a 1G file before it failed.
>
> root@ash:~ # ethtool -g eth0
> Ring parameters for eth0:
> Pre-set maximums:
> RX:             4096
> RX Mini:        0
> RX Jumbo:       0
> TX:             4096
> Current hardware settings:
> RX:             256
> RX Mini:        0
> RX Jumbo:       0
> TX:             1024
>
> I've pulled all the cards and looked - they are all genuine Intel C3922=
6-003=20
> (Pro/1000 MT)
> This page http://support.intel.com/support/network/sb/cs-005980-prd38.h=
tm
> says: 82541 Gigabit Small Form 32/66
> My system has PCI33 BTW.
>
> I have also tried 2.6.7 this morning and have the same problem.
>
> David
>
>
> module parameters.

I believe following is recommended by driver developers:
TxDescriptors=3D256 RxDescriptors=3D256 FlowControl=3D0 XsumRX=3D0

Cheers,
Jens L=E5=E5s

-----------------------------------------------------------------------
     'This mail automatically becomes portable when carried.'
-----------------------------------------------------------------------
     Jens L=E5=E5s                              Email: jens.laas@data.slu=
.se
     Department of Computer Services, SLU   Phone: +46 18 67 35 15
     Vindbrov=E4gen 1
     P.O. Box 7079
     S-750 07 Uppsala
     SWEDEN=20
-----------------------------------------------------------------------
--8323328-701340058-1087545847=:1089--
