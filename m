From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: GRO support in the bridge
Date: Wed, 10 Aug 2011 08:08:31 -0700
Message-ID: <20110810080831.05de9a5f@nehalam.ftrdhcpuser.net>
References: <1312884184.2170.YahooMailNeo@web110401.mail.gq1.yahoo.com>
	<1312958391.84140.YahooMailNeo@web110415.mail.gq1.yahoo.com>
	<1312979355.53304.YahooMailNeo@web110404.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sedat Cakir <cakir_sedat@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57331 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752915Ab1HJPIw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2011 11:08:52 -0400
In-Reply-To: <1312979355.53304.YahooMailNeo@web110404.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 Aug 2011 05:29:15 -0700 (PDT)
Sedat Cakir <cakir_sedat@yahoo.com> wrote:

> Hi,=A0
>=20
>=20
>=20
> I am trying to understand why GRO is NOT enabled on the bridge. Is th=
ere a special reason for it? Reading the code in net/core/dev.c:2817 (_=
_netif_receieve_skb) which is what I think the bridge is calling becaus=
e that is what is passed in at br_input.c:br_pass_frame_up():24. I am w=
ondering if this can be modified to use one of the _gro_ receive functi=
ons and if so if that will positively impact performance? Do you have a=
ny idea?=20
>=20
> Appreciate your help.Thanks,
> Sedat

The reason is that GRO is related to NAPI.
GRO works by coalescing frames received in one NAPI interval
of work.  The bridge itself has no receive irq or NAPI and is upcalled
from the device receive handler. There is no expectation or
requirement that devices in a bridge use NAPI. Therefore it
is not possible or safe for bridge pseudo-device to use GRO.
