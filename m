From: "Martitz, Thomas" <thomas.martitz@hhi.fraunhofer.de>
Subject: Re: Trying to implement secondary loopback
Date: Fri, 15 Mar 2013 19:48:57 +0000
Message-ID: <3D7E565A361FB844A410A5EFCDD7BA40031932@MXSRV3.fe.hhi.de>
References: <514326FF.6020205@hhi.fraunhofer.de>
 <CAFLxGvwvH_krBDJ2i-si1LX2SKbeeRmXGR+0ZbtEB2oKWt-GoA@mail.gmail.com>
 <51432B72.20408@hhi.fraunhofer.de>
 <CAFLxGvyCFHk=vhNYCY8obrVJR2rW9M7+J_ppyVpFq3AHAxjRjA@mail.gmail.com>
 <51432E13.5060003@hhi.fraunhofer.de>
 <CAFLxGvyDaaOtm1TrD-gfvhja_Uow8jtRbPyb2WcMscSLgo1umg@mail.gmail.com>
 <514331BC.4080802@hhi.fraunhofer.de>
 <CAFLxGvyzkoj_KtfH6=YK5LnpLW_N6sMdk7Hu=V=h5OK08oRE4Q@mail.gmail.com>
 <5143353C.3050107@hhi.fraunhofer.de>
 <51433934.3080405@hhi.fraunhofer.de>,<20130315153740.GR8869@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richard -rw- weinberger <richard.weinberger@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"edumazet@google.com" <edumazet@google.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.HHI.FRAUNHOFER.DE ([193.174.67.45]:54855 "EHLO
	mailgw.hhi.fraunhofer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754248Ab3COTtA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 15:49:00 -0400
In-Reply-To: <20130315153740.GR8869@kvack.org>
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> ________________________________________
> Von: Benjamin LaHaise [bcrl@kvack.org]
> Gesendet: Freitag, 15. M=E4rz 2013 16:37
> An: Martitz, Thomas
> Cc: richard -rw- weinberger; Eric W. Biederman; netdev@vger.kernel.or=
g; davem@davemloft.net; edumazet@google.com; herbert@gondor.apana.org.a=
u
> Betreff: Re: Trying to implement secondary loopback
>
> On Fri, Mar 15, 2013 at 04:07:32PM +0100, Thomas Martitz wrote:
> > Same result. I assumed the kernel treats lo in a special way for
> > localhost-connections and that it would be impossible to achieve th=
e
> > same with a custom interface.
> >
> > I did the following:
> >
> > ifconfig lo down
> > insmod ./mykmod.ko
> > ifconfig eth2 up
> > ifconfig eth2 127.0.0.1
> >
> > At this point ifconfig prints the same information for eth2 that it=
 had
> > printed for lo before (except for the LOOPBACK flag, but I can enab=
le
> > that one as well by adding IFF_LOOPBACK to the interface flags in t=
he
> > module). Yet my test application only works with lo, not eth2.
>
> Don't use loopback ip addresses; it makes no sense to do so.  I've wo=
rked
> on a couple opf nic implementations on FPGAs for a while now (a gige
> implementation that works, and now a 10G nic), and it's easy enough t=
o
> develop it as a regular ethernet driver.  You can write test programs=
 that
> use raw sockets to send/receive packets over the ethernet device, or =
use
> pktgen to send packets.  You don't even need to configure an ip addre=
ss for
> testing with raw packets.  Testing with IP is a lot harder during ear=
ly
> bring-up of your hardware as it requires everything to work (that is,=
 you
> need ARP to work successfully before IP can work).  Just stick to sim=
ple
> packet injection initially, and don't confuse yourself by thinking ab=
out
> the loopback device.

Thank you for your very helpful mail. I haven't considered raw sockets,=
 but it makes total sense now you mention it. This should give a lot le=
ss hassle.

However, please let us try to clear up my (mis-)understanding. Even whe=
n I use non-looback addresses (e.g. 192.168.1.x) it does not work. For =
the ARP requirement I tried to workaround by using specifying the IFF_N=
OARP flag, and using the arp command line tool to populate the arp cach=
e with the the MAC. With this, and all other interfaces down'ed, I cann=
ot get transfers to work. The the sendto() (sending UDP datadagrams) ca=
ll hangs while the ndk_start_xmit() method isn't even called. As works =
fine with the loopback interface I started to believe that I need to im=
plement a real loopback interface. It is this supposed to work this way=
 isn't it?

Best regards.
-----
visit us at

OFC 2013 / March 19-21 / Anaheim Convention Center, CA, USA / booth 118=
07

NABSHOW 2013 / April 8-11 / Las Vegas Convention Center, Nevada, USA / =
booth C7843

www.hhi.fraunhofer.de/events
