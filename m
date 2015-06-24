From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 1/2] sh_eth: Remove obsolete r7s72100-ether
 platform_device_id entry
Date: Wed, 24 Jun 2015 09:48:15 +0200
Message-ID: <CAMuHMdWZ3k8z7iBPsoj9g5uiKmQ-FiznQxqXoaNXO2nq+8gjjw@mail.gmail.com>
References: <1435064462-11680-1-git-send-email-geert+renesas@glider.be>
	<20150624.005537.1031818561162918702.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Geert Uytterhoeven <geert+renesas@glider.be>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:36233 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbbFXHsQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 03:48:16 -0400
In-Reply-To: <20150624.005537.1031818561162918702.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, Jun 24, 2015 at 9:55 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Geert Uytterhoeven <geert+renesas@glider.be>
> Date: Tue, 23 Jun 2015 15:01:01 +0200
>
>> Since commit 05104c266ae9a167 ("ARM: shmobile: r7s72100: genmai: Rem=
ove
>> legacy board file"), r7s72100 is only supported in generic DT-only A=
RM
>> multi-platform builds.  The driver doesn't need to match platform
>> devices by name anymore, hence remove the corresponding
>> platform_device_id entry.
>>
>> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
>
> These two changes are incomplete, please compile test your changes an=
d
> look for warnings:
>
> drivers/net/ethernet/renesas/sh_eth.c:493:31: warning: =E2=80=98r8a77=
9x_data=E2=80=99 defined but not used [-Wunused-variable]
> drivers/net/ethernet/renesas/sh_eth.c:803:31: warning: =E2=80=98r7s72=
100_data=E2=80=99 defined but not used [-Wunused-variable]

You're right. They're still used for DT matching, but I missed that
sh_eth_match_table[] is protected by #ifdef CONFIG_OF, which is always =
set
on ARM these days.

Sorry about that, will fix.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
                                -- Linus Torvalds
