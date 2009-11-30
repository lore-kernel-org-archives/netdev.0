From: Grant Grundler <grundler@google.com>
Subject: Re: dmfe/tulip device id overlap
Date: Mon, 30 Nov 2009 09:14:01 -0800
Message-ID: <da824cf30911300914p2d08b87cr4625e9bc30ec7e5b@mail.gmail.com>
References: <20091125043603.GK14043@jenkins.home.ifup.org>
	 <20091125044944.GL14043@jenkins.home.ifup.org>
	 <da824cf30911250924i31f77033r7f60027ed74b2cd@mail.gmail.com>
	 <20091129.003024.245104886.davem@davemloft.net>
	 <20091130065512.GA2792@jenkins.domain_not_set.invalid>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, tobias@ringis.se,
	kyle@mcmartin.ca, netdev@vger.kernel.org, grundler@parisc-linux.org
To: Brandon Philips <brandon@ifup.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:16266 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753093AbZK3ROD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 12:14:03 -0500
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id nAUHE5a6004947
	for <netdev@vger.kernel.org>; Mon, 30 Nov 2009 09:14:06 -0800
Received: from ey-out-1920.google.com (eyg4.prod.google.com [10.208.7.4])
	by wpaz21.hot.corp.google.com with ESMTP id nAUHE1sX016593
	for <netdev@vger.kernel.org>; Mon, 30 Nov 2009 09:14:02 -0800
Received: by ey-out-1920.google.com with SMTP id 4so642500eyg.6
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2009 09:14:01 -0800 (PST)
In-Reply-To: <20091130065512.GA2792@jenkins.domain_not_set.invalid>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 29, 2009 at 10:55 PM, Brandon Philips <brandon@ifup.org> wr=
ote:
> Hello Dave-
>
> On 00:30 Sun 29 Nov 2009, David Miller wrote:
>> From: Grant Grundler <grundler@google.com>
>> Date: Wed, 25 Nov 2009 09:24:54 -0800
>>
>> > I'm ok with this patch except the mention of Ubuntu in the comment=
 is
>> > superfluous. All the distro's will share this problem. I trust dav=
em
>> > to rewrite the comment and plase add my:
>> > =C2=A0 =C2=A0 Signed-off-by: Grant Grundler <grundler@parisc-linux=
=2Eorg>
>>
>> Please remove the comment and the __sparc__ ifdef.
>
> The comment and the __sparc__ ifdef is the entire patch... so you NAC=
K
> the whole patch?? ;)
>
>> If tulip doesn't work on some sparc systems we simply need to fix
>> it.
>
> Tulip works on sparc as described in the linux-sparc[1] thread. =C2=A0=
The
> problem as I understand it:
>
> tulip works for the 0x9100 and 0x9102 parts that were onboard a few
> sparc motherboards.

Has anyone posted "lspci -v" output for the "Netra X1 and Sunfire
V100" motherboards?

I'm asking because I'm hoping it's possible to disambiguate the add-on
cards from
LAN-on-Motherboard cases by looking at subsystem vendor and device IDs =
as well.
If we are lucky, those subsystem ID to use "Sun Microsystems" Vendor ID=
s:
    http://www.pcidatabase.com/vendor_details.php?id=3D526

and this will be easy to resolve.

> But, those same device IDs are used by a set of Davicom PCI cards tha=
t
> only work with the dmfe driver.
>
> Thus, the patch only lets tulip handle 0x9100 and 0x9102 if __sparc__=
=2E
>
> Perhaps someone knows if there is a way to tell the PCI card from the
> sparc builtin machine?

Do any add-on DMFE devices have OpenBOOT firmware support?
(e.g. for the Mac?) My expectation is the SPARC motherboard
devices do but that needs to be confirmed.

To be clear, I have no interest in merging dmfe driver support into
tulip driver.
I'm open to review patches that do that (and test them). Right now, I'd
only like to resolve the immediate problem SPARC users are seeing
since that seems to be pretty straight forward.

hth,
grant

>
> Cheers,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Brandon
>
> [1] http://marc.info/?l=3Dlinux-sparc&m=3D123698696912216&w=3D2
>
