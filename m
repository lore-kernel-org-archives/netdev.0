From: Grant Grundler <grundler@google.com>
Subject: Re: dmfe/tulip device id overlap
Date: Wed, 25 Nov 2009 09:24:54 -0800
Message-ID: <da824cf30911250924i31f77033r7f60027ed74b2cd@mail.gmail.com>
References: <20091125043603.GK14043@jenkins.home.ifup.org>
	 <20091125044944.GL14043@jenkins.home.ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tobias Ringstrom <tobias@ringis.se>,
	Kyle McMartin <kyle@mcmartin.ca>, davem@davemloft.net,
	netdev@vger.kernel.org, Grant Grundler <grundler@parisc-linux.org>
To: Brandon Philips <brandon@ifup.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:35170 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759441AbZKYRZC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 12:25:02 -0500
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id nAPHOx7u013991
	for <netdev@vger.kernel.org>; Wed, 25 Nov 2009 09:25:01 -0800
Received: from ey-out-2122.google.com (eye22.prod.google.com [10.208.5.22])
	by spaceape10.eur.corp.google.com with ESMTP id nAPHOslt004334
	for <netdev@vger.kernel.org>; Wed, 25 Nov 2009 09:24:55 -0800
Received: by ey-out-2122.google.com with SMTP id 22so732348eye.15
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2009 09:24:54 -0800 (PST)
In-Reply-To: <20091125044944.GL14043@jenkins.home.ifup.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2009 at 8:49 PM, Brandon Philips <brandon@ifup.org> wro=
te:
> Adding Tobias and Grant under (hopefully) working email addresses.
>
> Can you please submit patches to update MAINTAINERS with your
> preferred email?

grundler@parisc-linux.org is my preferred email for tulip driver
issues. Is that bouncing? :(


> On 20:36 Tue 24 Nov 2009, Brandon Philips wrote:
>> Hello All-
>>
>> dmfe and tulip have an overlap of device IDs and it has been discuss=
ed
>> before without resolution[1][2].
>>
>> The device ID in particular is:
>>
>> =C2=A0 =C2=A0 =C2=A0 { 0x1282, 0x9100, PCI_ANY_ID, PCI_ANY_ID, 0, 0,=
 DM910X },
>> =C2=A0 =C2=A0 =C2=A0 { 0x1282, 0x9102, PCI_ANY_ID, PCI_ANY_ID, 0, 0,=
 DM910X },
>>
>> Users of Fedora[3] and openSUSE[4] are feeling pain from this but
>> Ubuntu users are avoiding the issue do to the patch below.
>>
>> This patch comes almost directly from the discussion on the
>> linux-sparc thread[2]. So, can we merge that patch? Or can one of th=
e
>> maintainers come up with a less hacky solution (e.g. fix tulip)?

I'm totally ok with "clipping" the DMFE ids so tulip and dmfe drivers
have no overlap. I just can't test it since I don't have those cards.
It sounds like people know which driver works on sparc.


>>
>> Cheers,
>>
>> =C2=A0 =C2=A0 =C2=A0 Brandon
>>
>> [1] http://www.mail-archive.com/debian-sparc@lists.debian.org/msg216=
47.html
>> [2] http://marc.info/?l=3Dlinux-sparc&m=3D123698905214250&w=3D2
>> [3] https://bugzilla.redhat.com/show_bug.cgi?id=3D277731
>> [4] https://bugzilla.novell.com/show_bug.cgi?id=3D537016
>>
>> From: Ben Collins <bcollins@ubuntu.com>
>> Date: Wed, 18 Jul 2007 17:48:25 +0000 (-0400)
>> Subject: UBUNTU: SAUCE: tulip: Let dmfe handle davicom on non-sparc
>> X-Git-Tag: Ubuntu-2.6.31-10.31~680
>> X-Git-Url: http://kernel.ubuntu.com/git?p=3Dubuntu%2Fubuntu-karmic.g=
it;a=3Dcommitdiff_plain;h=3D886595ab493b5c5fcf23b55b3ebf46bfe219a5d0
>>
>> UBUNTU: SAUCE: tulip: Let dmfe handle davicom on non-sparc
>>
>> Signed-off-by: Ben Collins <ben.collins@canonical.com>

I'm ok with this patch except the mention of Ubuntu in the comment is
superfluous. All the distro's will share this problem. I trust davem
to rewrite the comment and plase add my:
    Signed-off-by: Grant Grundler <grundler@parisc-linux.org>

cheers,
grant

>> ---
>>
>> diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tuli=
p_core.c
>> index 4cf9a65..b75f65c 100644
>> --- a/drivers/net/tulip/tulip_core.c
>> +++ b/drivers/net/tulip/tulip_core.c
>> @@ -228,8 +228,12 @@ static struct pci_device_id tulip_pci_tbl[] =3D=
 {
>> =C2=A0 =C2=A0 =C2=A0 { 0x1259, 0xa120, PCI_ANY_ID, PCI_ANY_ID, 0, 0,=
 COMET },
>> =C2=A0 =C2=A0 =C2=A0 { 0x11F6, 0x9881, PCI_ANY_ID, PCI_ANY_ID, 0, 0,=
 COMPEX9881 },
>> =C2=A0 =C2=A0 =C2=A0 { 0x8086, 0x0039, PCI_ANY_ID, PCI_ANY_ID, 0, 0,=
 I21145 },
>> + =C2=A0 =C2=A0 /* Ubuntu: On non-sparc, this seems to be handled be=
tter by the
>> + =C2=A0 =C2=A0 =C2=A0* dmfe driver. */
>> +#ifdef __sparc__
>> =C2=A0 =C2=A0 =C2=A0 { 0x1282, 0x9100, PCI_ANY_ID, PCI_ANY_ID, 0, 0,=
 DM910X },
>> =C2=A0 =C2=A0 =C2=A0 { 0x1282, 0x9102, PCI_ANY_ID, PCI_ANY_ID, 0, 0,=
 DM910X },
>> +#endif
>> =C2=A0 =C2=A0 =C2=A0 { 0x1113, 0x1216, PCI_ANY_ID, PCI_ANY_ID, 0, 0,=
 COMET },
>> =C2=A0 =C2=A0 =C2=A0 { 0x1113, 0x1217, PCI_ANY_ID, PCI_ANY_ID, 0, 0,=
 MX98715 },
>> =C2=A0 =C2=A0 =C2=A0 { 0x1113, 0x9511, PCI_ANY_ID, PCI_ANY_ID, 0, 0,=
 COMET },
>
