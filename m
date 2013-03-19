From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net-next 1/5] GRE: Refactor GRE tunneling code.
Date: Tue, 19 Mar 2013 13:58:28 -0700
Message-ID: <20130319135828.0dd18d40@nehalam.linuxnetplumber.net>
References: <1363630405-1672-1-git-send-email-pshelar@nicira.com>
	<20130318122409.00c01106@nehalam.linuxnetplumber.net>
	<20130318.153319.206719819832403477.davem@davemloft.net>
	<87r4jb1y0t.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, pshelar@nicira.com,
	netdev@vger.kernel.org, jesse@nicira.com
To: =?ISO-8859-1?B?Qmr4cm4=?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f50.google.com ([209.85.210.50]:37088 "EHLO
	mail-da0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754782Ab3CSU6e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 16:58:34 -0400
Received: by mail-da0-f50.google.com with SMTP id t1so528827dae.23
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 13:58:34 -0700 (PDT)
In-Reply-To: <87r4jb1y0t.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 Mar 2013 11:31:30 +0100
Bj=F8rn Mork <bjorn@mork.no> wrote:

> David Miller <davem@davemloft.net> writes:
> > From: Stephen Hemminger <stephen@networkplumber.org>
> >> On Mon, 18 Mar 2013 11:13:25 -0700
> >> Pravin B Shelar <pshelar@nicira.com> wrote:
> >>=20
> >>> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> >>> index 7944df7..2073226 100644
> >>> --- a/net/ipv4/Kconfig
> >>> +++ b/net/ipv4/Kconfig
> >>> @@ -186,9 +186,14 @@ config NET_IPGRE_DEMUX
> >>>  	 This is helper module to demultiplex GRE packets on GRE versio=
n field criteria.
> >>>  	 Required by ip_gre and pptp modules.
> >>> =20
> >>> +config NET_IP_TUNNEL
> >>> +	tristate
> >>> +	default n
> >>> +
> >>=20
> >> Won't this break existing kernel config's, shouldn't this default =
y?
> >
> > Or "m".  But indeed, it should be made to automatically work for
> > existing configs.
>=20
> Won't the "select NET_IP_TUNNEL" statements do just that?
>=20
> Changing the default to m will enable this module even if all of
> NET_IPGRE, VXLAN and NET_IPIP are disabled. That's pointless, isn't i=
t?

Looks like you are right, just tried a number of different kernel
configs with 'make oldconfig' and it picks up the dependency  correctly=
=2E
