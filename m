From: Jens Laas <jens.laas@data.slu.se>
Subject: Re: 2.6.6 e1000 NETDEV WATCHDOG: eth0: transmit timed out+ delay
 scheduler
Date: Fri, 18 Jun 2004 12:27:43 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.60.0406181217060.1089@jlaas2.data.slu.se>
References: <40CDD68C.8070509@dgreaves.com> <20040615155111.26d6b809@dell_ss3.pdx.osdl.net>
 <40D0280B.2030308@dgreaves.com> <Pine.LNX.4.60.0406180953240.1089@jlaas2.data.slu.se>
 <40D2B114.5020201@dgreaves.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-271200117-1087554463=:1089"
Cc: Jens Laas <jens.laas@data.slu.se>, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com, ganesh.venkatesan@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Greaves <david@dgreaves.com>
In-Reply-To: <40D2B114.5020201@dgreaves.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-271200117-1087554463=:1089
Content-Type: TEXT/PLAIN; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by mail1.slu.se id i5IARh8e009653

(04.06.18 kl.10:08) David Greaves skrev f=F6ljande till Jens Laas:

> Stephen, I applied your delay scheduler patch and some results appear b=
elow.
>
> Jens Laas wrote:
>
>> (04.06.16 kl.11:59) David Greaves skrev f=F6ljande till Stephen Hemmin=
ger:
>>=20
>> We have seen the same symptoms. (2.6.x + e1000)
>>=20
>> Our system is an SMP system. That might be whats triggering the proble=
m.
>> Is your system UP or SMP ?
>
> UP

Ok. This keeps getting stranger..


>
>> (Next reboot we will test running on only one CPU).
>>=20
>> We have tried with and without NAPI, both exhibit the same problem.
>
> Me too
>
>> We have tried different versions of e1000 without luck.
>
...
>> Make sure that flowcontrol is disabled on your switch (if it has it=20
>> implemented).
>
> ...so it's not that smart anymore ;)
>
>>>=20
>>> module parameters.
>>=20
>>=20
>> I believe following is recommended by driver developers:
>> TxDescriptors=3D256 RxDescriptors=3D256 FlowControl=3D0 XsumRX=3D0
>
> Yes, I'm running with module defaults unless otherwise stated but I've =
tried=20
> that combo (to no effect)

No effect here either. FlowControl and XsumRX are known troublemakers.

>
> I'm speaking with Ganesh Venkatesan at intel about it. Ganesh you went =
off=20
> list - do you want to include Jens or maybe go back on-list?

If others run into this problem I'm sure they'll appreciate if its on=20
list.
Since we have no idea what causes this (AFAIK) it may be a more general=20
problem than the device driver.

>
> A simple failure case for me is : 'ping -s 1500 '
> This doesn't cause the timout but doesn't succeed either.
>
> ping -f with standard packet size succeeds (slow rate though) and doesn=
't=20
> timeout.

I dont see the ping problems at all. Unless you try to ping when the=20
interface has "hanged" ?


>
> Using 8139 100Mbs card:
> 272384 packets transmitted, 272383 packets received, 0% packet loss
> round-trip min/avg/max =3D 0.1/0.1/4.0 ms
> real    0m32.179s
>
> Using Pro/1000:
> 60992 packets transmitted, 60991 packets received, 0% packet loss
> round-trip min/avg/max =3D 0.0/0.5/8.4 ms
> real    0m38.257s
>
> any ping with -s >1500 results in 100% packet loss.
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> From hereon down it's 2.6.7 with Stephen's recent delay scheduler patch
>
> This changed the behaviour.

This is strange unless you are actually using the delay scheduler ?
Default is sch_generic (that is pfifo) that does not exhibit the problems=
=20
correct by the patch.


> 10592 packets transmitted, 10591 packets received, 0% packet loss
> round-trip min/avg/max =3D 5.4/5.5/83.5 ms
>
> Increasing Transmit Descriptors to 4096 avoids the No buffer space avai=
lable=20
> with packet sizes up to -s65468 (still 100% failure though)

Increasing nr of buffers is not a way to fix the problem.

I had hoped to hear something about this from Scott..

Cheers,
Jens

>
> I'm not sure that adds much now so I'll leave it until I get some more=20
> suggestions.
>
> HTH
>
> David
>

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
--8323328-271200117-1087554463=:1089--
