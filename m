From: Christian Zigotzky <chzigotzky@xenosoft.de>
Subject: [P.A. Semi] Does the ethernet interface work on your Electra, Chitra,
 Nemo, and Athena board?
Date: Thu, 3 Dec 2015 13:37:27 +0100
Message-ID: <56603787.3000802@xenosoft.de>
References: <565AF986.9060106@xenosoft.de>
 <CAOJe8K1911vDjMe9m_1vY6DSGpOk0TmL96Qf1whuNFXxHJesGw@mail.gmail.com>
 <565C1B55.4020207@xenosoft.de> <565C8287.7090209@xenosoft.de>
 <20151130181217.GA15921@visitor2.iram.es> <565DB2FE.1010706@xenosoft.de>
 <565E7A9E.4000909@xenosoft.de> <1449044072.24750.3.camel@ellerman.id.au>
 <565F5E7C.9040207@xenosoft.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Michael Ellerman <mpe@ellerman.id.au>,
	Gabriel Paubert <paubert@iram.es>, netdev@vger.kernel.org,
	Denis Kirjanov <kda@linux-powerpc.org>,
	linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.220]:28681 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759679AbbLCMht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 07:37:49 -0500
In-Reply-To: <565F5E7C.9040207@xenosoft.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael,

I checked out the Linux git till the commit 'powerpc-4.3-1'

git checkout ff474e8ca8547d09cb82ebab56d4c96f9eea01ce

Output:

Checking out files: 100% (13843/13843), done.
Note: checking out 'ff474e8ca8547d09cb82ebab56d4c96f9eea01ce'.

You are in 'detached HEAD' state. You can look around, make experimenta=
l
changes and commit them, and you can discard any commits you make in th=
is
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you ma=
y
do so (now or later) by using -b with the checkout command again. Examp=
le:

   git checkout -b new_branch_name

HEAD ist jetzt bei ff474e8... Merge tag 'powerpc-4.3-1' of=20
git://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux

---

The P.A. Semi Ethernet doesn't work with the powerpc-4.3-1 merge. I=20
reverted this merge with:

git revert ff474e8ca8547d09cb82ebab56d4c96f9eea01ce -m 1

Output:

  Committer: christian <christian@AmigaoneX1000.lan>
Ihr Name und E-Mail Adresse wurden automatisch auf Basis
Ihres Benutzer- und Rechnernamens konfiguriert. Bitte pr=C3=BCfen Sie, =
dass
diese zutreffend sind. Sie k=C3=B6nnen diese Meldung unterdr=C3=BCcken,=
 indem Sie
diese explizit setzen:

     git config --global user.name "Ihr Name"
     git config --global user.email ihre@emailadresse.de

Nachdem Sie das getan hast, k=C3=B6nnen Sie Ihre Identit=C3=A4t f=C3=BC=
r diesen Commit=20
=C3=A4ndern mit:

     git commit --amend --reset-author

  146 files changed, 2047 insertions(+), 3609 deletions(-)
  delete mode 100644 Documentation/devicetree/bindings/leds/leds-powern=
v.txt
  delete mode 100644 Documentation/devicetree/bindings/powerpc/fsl/scfg=
=2Etxt
  delete mode 100644 arch/powerpc/boot/dts/t1040d4rdb.dts
  delete mode 100644 arch/powerpc/boot/dts/t1042d4rdb.dts
  delete mode 100644 arch/powerpc/boot/dts/t104xd4rdb.dtsi
  delete mode 100644 arch/powerpc/configs/85xx-32bit.config
  delete mode 100644 arch/powerpc/configs/85xx-64bit.config
  delete mode 100644 arch/powerpc/configs/85xx-hw.config
  delete mode 100644 arch/powerpc/configs/85xx-smp.config
  delete mode 100644 arch/powerpc/configs/altivec.config
  create mode 100644 arch/powerpc/configs/corenet32_smp_defconfig
  rename arch/powerpc/configs/{fsl-emb-nonhw.config =3D>=20
corenet64_smp_defconfig} (50%)
  delete mode 100644 arch/powerpc/configs/corenet_basic_defconfig
  delete mode 100644 arch/powerpc/configs/mpc85xx_basic_defconfig
  create mode 100644 arch/powerpc/configs/mpc85xx_defconfig
  create mode 100644 arch/powerpc/configs/mpc85xx_smp_defconfig
  delete mode 100644 arch/powerpc/include/asm/trace_clock.h
  delete mode 100644 arch/powerpc/kernel/trace_clock.c
  rewrite arch/powerpc/platforms/powernv/opal-power.c (76%)
  delete mode 100644 drivers/leds/leds-powernv.c

---

After that the P.A. Semi Ethernet works without any problems.

Cheers,

Christian

On 02 December 2015 at 10:11 PM, Christian Zigotzky wrote:
> Hi Michael,
>
> Thanks a lot for your answer. We tested some vanilla mainline 4.3=20
> kernels on an Electra reference board. Additionally we tested some=20
> patched 4.3 kernels on our Nemo boards.
>
> It would be really fantastic, if you could fix the problem.
>
> Cheers,
>
> Christian
>
> On 02 December 2015 at 09:14 AM, Michael Ellerman wrote:
>> On Wed, 2015-12-02 at 05:59 +0100, Christian Zigotzky wrote:
>>> Hi all,
>>>
>>> We tested some 4.3 kernels on a P.A. Semi reference board. Ultimate=
ly,
>>> ethernet does not work, though on the reference board, the interfac=
e is
>>> detected, gets link, but will not pass any packets/traffic.
>>>
>>> Somewhere in the source code of the commit "'powerpc-4.3-1' of
>>> git://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux (2015-0=
9-03
>>> 23:41:38 (GMT)" is the problem.
>>>
>>> Could you please help us to solve the problem?
>> Hi Christian,
>>
>> Unfortunately there is no source code in that commit, it's just a=20
>> merge. And
>> your bisect run found that the very first commit in that merge was O=
K:
>>
>>>> [390fd5929f52bdfb9dfcc03820041ba556780f4a] cxl: Set up and enable =
PSL
>>>> git bisect good
>> So I'm not convinced your bisect run was correct, sorry.
>>
>> My pasemi is booting OK, but I haven't had time to test the network.=
=20
>> If you
>> remind me next week I will make sure network is working on my board.
>>
>> Are you testing your board with your additional patch as well? Or=20
>> just vanilla
>> mainline?
>>
>> cheers
>>
>> _______________________________________________
>> Linuxppc-dev mailing list
>> Linuxppc-dev@lists.ozlabs.org
>> https://lists.ozlabs.org/listinfo/linuxppc-dev
>
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev
