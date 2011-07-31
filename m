From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [net-next v2 03/71] amd: Move AMD (Lance) chipset drivers
Date: Sun, 31 Jul 2011 10:14:34 +0200
Message-ID: <CAMuHMdXYoKkZrczdB6qPC1pfAGoTqgOiK2joY-38dewrVm5cRQ@mail.gmail.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1312082850-24914-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com,
	Peter Maydell <pmaydell@chiark.greenend.org.uk>,
	Roman Hodek <Roman.Hodek@informatik.uni-erlangen.de>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Donald Becker <becker@scyld.com>,
	Sam Creasey <sammy@users.qual.net>,
	Miguel de Icaza <miguel@nuclecu.unam.mx>,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	Don Fry <pcnet32@frontier.com>,
	Russell King <linux@arm.linux.org.uk>,
	David Davies <davies@maniac.ultranet.com>,
	"M.Hipp" <hippm@informatik.uni-tuebingen.de>,
	Pete Popov <ppopov@embeddedalley.com>,
	David Hinds <dahinds@users.sourceforge.net>,
	"Roger C. Pao" <rpao@paonet.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:63766 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752458Ab1GaIOf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2011 04:14:35 -0400
Received: by iyb12 with SMTP id 12so5666684iyb.19
        for <netdev@vger.kernel.org>; Sun, 31 Jul 2011 01:14:35 -0700 (PDT)
In-Reply-To: <1312082850-24914-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 31, 2011 at 05:26, Jeff Kirsher <jeffrey.t.kirsher@intel.co=
m> wrote:
> --- /dev/null
> +++ b/drivers/net/ethernet/amd/Kconfig
> @@ -0,0 +1,188 @@
> +#
> +# AMD network device configuration
> +#
> +
> +config NET_VENDOR_AMD
> + =C2=A0 =C2=A0 =C2=A0 bool "AMD devices"
> + =C2=A0 =C2=A0 =C2=A0 depends on DIO || MACH_DECSTATION || MVME147 |=
| ATARI || SUN3 || \
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0SUN3X=
 || SBUS || PCI || ZORRO || (ISA && ISA_DMA_API) || \
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(ARM =
&& ARCH_EBSA110) || ISA || EISA || MCA || PCMCIA

Do you really need this big dependency? It will be true in almost all
cases anyway,
and the individual driver options are protected by other dependencies.
Just enabling this option doesn't make the kernel bigger.

> + =C2=A0 =C2=A0 =C2=A0 ---help---
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 If you have a network (Ethernet) chipse=
t belonging to this class,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 say Y.
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 Note that the answer to this question d=
oes not directly affect
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 the kernel: saying N will just case the=
 configurator to skip all
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 the questions regarding AMD chipsets. I=
f you say Y, you will be asked
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 for your specific chipset/driver in the=
 following questions.
> +
> +config A2065
> + =C2=A0 =C2=A0 =C2=A0 tristate "A2065 support"
> + =C2=A0 =C2=A0 =C2=A0 depends on NET_VENDOR_AMD && ZORRO

What about putting all driver sections inside "if NET_VENDOR_AMD" /
"endif", so the
individual driver configs don't need to depend on NET_VENDOR_AMD anymor=
e?

The rest looks fine to me.

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds
