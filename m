From: richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: [PATCH] 3c59x: Don't assign when a comparison is intended
Date: Sat, 25 Dec 2010 22:00:48 +0100
Message-ID: <AANLkTi=yFm+kwXJbFrotTNmWky1J7O8=qVg7rhq=HxZG@mail.gmail.com>
References: <alpine.LNX.2.00.1012252125410.10759@swampdragon.chaosbits.net>
	<AANLkTi=Y4wDG6+AY1=8NuFLGuCidgqaU1LginfB1YpZH@mail.gmail.com>
	<alpine.LNX.2.00.1012252144030.10759@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	linux-kernel@vger.kernel.org
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1012252144030.10759@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 25, 2010 at 9:45 PM, Jesper Juhl <jj@chaosbits.net> wrote:
> On Sat, 25 Dec 2010, richard -rw- weinberger wrote:
>
>> On Sat, Dec 25, 2010 at 9:30 PM, Jesper Juhl <jj@chaosbits.net> wrot=
e:
>> > Hi,
>> >
>> > In drivers/net/3c59x.c::vortex_probe1() we have this code:
>> >
>> > =A0 =A0 =A0 =A0if (gendev) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((pdev =3D DEVICE_PCI(gendev))) =
{
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0print_name =3D pci_=
name(pdev);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((edev =3D DEVICE_EISA(gendev)))=
 {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0print_name =3D dev_=
name(&edev->dev);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> > =A0 =A0 =A0 =A0}
>> >
>> > I believe these assignments were intended to be comparisons.
>> > If I'm correct, then here's a patch to fix that up.
>>
>> I don't think so. Look at the extra brackets.
>>
>> The code can also written as:
>>
>> pdev =3D DEVICE_PCI(gendev);
>> if(pdev)
>> =A0 print_name =3D pci_name(pdev);
>>
>
> Arrgh, I completely missed that - damn.
> You are correct I think and my patch is wrong.
> Thanks for taking a look.

BTW: gcc is smart enough to catch such typos.

if(x =3D 3){
 ...
}

=2E..would trigger a warning like this one:
"warning: suggest parentheses around assignment used as truth value"

>
> --
> Jesper Juhl <jj@chaosbits.net> =A0 =A0 =A0 =A0 =A0 =A0http://www.chao=
sbits.net/
> Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
> Plain text mails only, please.
>

--=20
Thanks,
//richard
