From: =?iso-8859-1?Q?Bj=F6rn?= Steinbrink <B.Steinbrink@gmx.de>
Subject: Re: [PATCH] Fix forcedeth reversing the MAC address on suspend
Date: Mon, 7 Jan 2008 02:47:56 +0100
Message-ID: <20080107014756.GB4170@atjola.homenet>
References: <477BFC71.7090002@coderworld.net> <20080102214843.GA19224@rhlx01.hs-esslingen.de> <20080102234209.GA10831@does.not.exist> <20080104034357.GA2113@atjola.homenet> <477E3DEA.4070001@coderworld.net> <20080104222633.GA21133@atjola.homenet>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Adrian Bunk <bunk@kernel.org>,
	Andreas Mohr <andi@lisas.de>,
	Ayaz Abdulla <aabdulla@nvidia.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Richard Jonsson <richie@coderworld.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:40174 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752628AbYAGBr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jan 2008 20:47:59 -0500
Content-Disposition: inline
In-Reply-To: <20080104222633.GA21133@atjola.homenet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2008.01.04 23:26:33 +0100, Bj=F6rn Steinbrink wrote:
> For cards that initially have the MAC address stored in reverse order=
,
> the forcedeth driver uses a flag to signal whether the address was
> already corrected, so that it is not reversed again on a subsequent
> probe.
>=20
> Unfortunately this flag, which is stored in a register of the card,
> seems to get lost during suspend, resulting in the MAC address being
> reversed again. To fix that, the MAC address needs to be written back=
 in
> reversed order before we suspend and the flag needs to be reset.
>=20
> The flag is still required because at least kexec will never write ba=
ck
> the reversed address and thus needs to know what state the card is in=
=2E
>=20
> Signed-off-by: Bj=F6rn Steinbrink <B.Steinbrink@gmx.de>
> ---
> On 2008.01.04 15:08:42 +0100, Richard Jonsson wrote:
> > Bj=F6rn Steinbrink skrev:
> >> Richard, could you give this a spin? And then we'd likely need som=
eone
> >> to test that with kexec...
> >
> > The patch you sent does the trick, works fine now, thanks!
> > I cannot test this with kexec as I barely know what it is, I'll lea=
ve that=20
> > to someone else.
>=20
> Thanks.
>=20
> Ayaz, you originally wrote the kexec fix (IIRC), was my analysis of t=
he
> problem correct? If so, I'm quite sure that the patch DTRT. Still it
> should be tested for the rmmod+modprobe and the kexec case. I'll try =
to
> get my box free for some testing, but that's unlikely in the next few
> days. Plus, I've never used kexec myself either. So I'd be grateful i=
f
> someone else would step up.

=46ound a few minutes to test, but kexec would just hang for me. So I'm
unable to test that atm. :-(

Bj=F6rn
