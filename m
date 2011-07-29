From: T C <tccheung1@gmail.com>
Subject: Re: Kernel IPSec Questions
Date: Fri, 29 Jul 2011 10:56:18 -0700
Message-ID: <CAL0-=WwDFeCJX62_Bgty615MtjuBY3rBp6BtHP7p9_3NvJ3u+g@mail.gmail.com>
References: <CAL0-=Wwb+T_VYgMnOW9UiqQ2gVe8FaJCZgcFmHMLX1Yv3tVAdQ@mail.gmail.com>
	<4E325B58.6030202@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Andreas Steffen <andreas.steffen@strongswan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:51675 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210Ab1G2R4T convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 13:56:19 -0400
Received: by iyb12 with SMTP id 12so4216772iyb.19
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 10:56:18 -0700 (PDT)
In-Reply-To: <4E325B58.6030202@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andreas,

Thanks for the URLs.  I'll look thru them.

As far as strongswan is concerned, Martin has been very helpful in
explaining all the active actions that StrongSwan takes from
the user side.  So actions taken by IKE daemon based on configuration
files I already have info on that.  However,
the part that remains mostly unfamiliar is those actions taken by the
kernel during rekeying by sending messages back
from the kernel to the IKE daemon.  Do you happen to know anything
about that?  How are those actions trigged and what
happens to the communication channels during rekeying is what I am
most interested in finding out.  If your URLs already
contain something that'll point to those, I'll find out from them.  If
there is additional info on this, could you share them
as well?

Thanks,
Terry

On Fri, Jul 29, 2011 at 12:03 AM, Andreas Steffen
<andreas.steffen@strongswan.org> wrote:
> Hello Terry,
>
> here a repost of my email including the netdev list and fixing
> the last URL which was wrong.
>
> Here the definition of strongSwan's IPsec high level kernel interface
>
> http://git.strongswan.org/?p=3Dstrongswan.git;a=3Dblob;f=3Dsrc/libhyd=
ra/kernel/kernel_ipsec.h;h=3D986e21fca1bbd109445e95d86dbf458095299573;h=
b=3DHEAD
>
> and here the link to the kernel-netlink plugin which implements
> configuration and management of IPsec Policies and SAs via XFRM
>
> http://git.strongswan.org/?p=3Dstrongswan.git;a=3Dblob;f=3Dsrc/libhyd=
ra/plugins/kernel_netlink/kernel_netlink_ipsec.c;h=3D06720a0f4bddf9fde6=
0288f796df0eca647ae995;hb=3DHEAD
>
> Our plugin of course relies on the ipsec.h, netlink.h, rtnetlink.h,
> and xfrm.h Linux header files which define the API of the XFRM Netlin=
k
> kernel interface
>
> http://git.strongswan.org/?p=3Dstrongswan.git;a=3Dtree;f=3Dsrc/includ=
e/linux;h=3Da41d3e9a10954c47aff2efeb06576f323c039483;hb=3DHEAD
>
> Much more documentation than the Linux header files and the XFRM kern=
el
> source code itself does not exist.
>
> Finally a link which shows how strongSwan installs, updates, queries
> and deletes IPsec Policies and SAs
>
> http://git.strongswan.org/?p=3Dstrongswan.git;a=3Dblob;f=3Dsrc/libcha=
ron/sa/child_sa.c;h=3Dcda150f8736d010cf8d897071427daf8a02a337a;hb=3DHEA=
D
>
> Just look for all "hydra->kernel_interface" function calls.
>
> Best regards
>
> Andreas
>
> On 07/29/2011 07:40 AM, T C wrote:
>> Hi all,
>>
>> I have some questions on how IPSec logic works in the kernel. =A0The=
re might be
>> a difference between when XFRM was introduced and prior. =A0If possi=
ble,
>> I like to know both scenarios. =A0If not, at least from XFRM perspec=
tive would
>> be very helpful.
>>
>> Specifically, I am interested in knowing how does IPSec obtain the i=
nitial keys
>> from IKE exchange (and likely from XFRM) to set up the SA. =A0 Also =
what happens
>> during rekeying? =A0Does the SA have to be terminated first, or some=
how it can be
>> rekey'ed and continue as the same SA? =A0I'll be using strongswan fo=
r IKE.
>>
>> Function names and if possible some flow graphs would be greatly app=
reciated.
>>
>> Thanks,
>> Terry
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
>
> --
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Andreas Steffen =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 andre=
as.steffen@strongswan.org
> strongSwan - the Linux VPN Solution! =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0w=
ww.strongswan.org
> Institute for Internet Technologies and Applications
> University of Applied Sciences Rapperswil
> CH-8640 Rapperswil (Switzerland)
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D[ITA-HSR]=3D=3D
>
