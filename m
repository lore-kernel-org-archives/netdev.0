From: Gertjan van Wingerde <gwingerde@gmail.com>
Subject: Re: [PATCH 01/11] Removing dead RT2800PCI_SOC
Date: Fri, 16 Jul 2010 09:18:37 +0200
Message-ID: <4C4007CD.2070504@gmail.com>
References: <cover.1279110894.git.siccegge@cs.fau.de>	<20100714131527.GB2352@tuxdriver.com>	<4C3DCD5C.1080705@openwrt.org>	<201007151041.55112.bzolnier@gmail.com> <AANLkTilqoYMMKYJT-YYbEzdnytUSYa0EylEiJ4x5xXXH@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Felix Fietkau <nbd@openwrt.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Ivo Van Doorn <ivdoorn@gmail.com>,
	Christoph Egger <siccegge@cs.fau.de>,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vamos-dev@i4.informatik.uni-erlangen.de,
	Luis Correia <luis.f.correia@gmail.com>
To: Helmut Schaa <helmut.schaa@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTilqoYMMKYJT-YYbEzdnytUSYa0EylEiJ4x5xXXH@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/16/10 08:57, Helmut Schaa wrote:
> On Thu, Jul 15, 2010 at 10:41 AM, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com <mailto:bzolnier@gmail.com>> wrote:
> 
>     On Wednesday 14 July 2010 04:44:44 pm Felix Fietkau wrote:
>     > On 2010-07-14 3:15 PM, John W. Linville wrote:
>     > > On Wed, Jul 14, 2010 at 02:52:14PM +0200, Ivo Van Doorn wrote:
>     > >> On Wed, Jul 14, 2010 at 2:46 PM, Luis Correia <luis.f.correia@gmail.com <mailto:luis.f.correia@gmail.com>> wrote:
>     > >> > On Wed, Jul 14, 2010 at 13:39, Christoph Egger <siccegge@cs.fau.de <mailto:siccegge@cs.fau.de>> wrote:
>     > >> >> While RT2800PCI_SOC exists in Kconfig, it depends on either
>     > >> >> RALINK_RT288X or RALINK_RT305X which are both not available in Kconfig
>     > >> >> so all Code depending on that can't ever be selected and, if there's
>     > >> >> no plan to add these options, should be cleaned up
>     > >> >>
>     > >> >> Signed-off-by: Christoph Egger <siccegge@cs.fau.de <mailto:siccegge@cs.fau.de>>
>     > >> >
>     > >> > NAK,
>     > >> >
>     > >> > this is not dead code, it is needed for the Ralink System-on-Chip
>     > >> > Platform devices.
>     > >> >
>     > >> > While I can't fix Kconfig errors and the current KConfig file may be
>     > >> > wrong, this code cannot and will not be deleted.
>     > >>
>     > >> When the config option was introduced, the config options RALINK_RT288X and
>     > >> RALINK_RT305X were supposed to be merged as well soon after by somebody (Felix?)
>     > >>
>     > >> But since testing is done on SoC boards by Helmut and Felix, I assume the code
>     > >> isn't dead but actually in use.
>     > >
>     > > Perhaps Helmut and Felix can send us the missing code?
>     > The missing code is a MIPS platform port, which is currently being
>     > maintained in OpenWrt, but is not ready for upstream submission yet.
>     > I'm not working on this code at the moment, but I think it will be
>     > submitted once it's ready.
> 
>     People are using automatic scripts to catch unused config options nowadays
>     so the issue is quite likely to come back again sooner or later..
> 
>     Would it be possible to improve situation somehow till the missing parts
>     get merged?  Maybe by adding a tiny comment documenting RT2800PCI_SOC
>     situation to Kconfig (if the config option itself really cannot be removed)
>     until all code is ready etc.?
> 
> 
> Or we could just remove RT2800PCI_SOC completely and build the soc specific
> parts always as part of rt2800pci. I mean it's not much code, just the platform
> driver stuff and the eeprom access.
> 

I'm not sure if that is feasible. Sure, we can reduce the usage of the variable by
unconditionally compiling in the generic SOC code, but we should not unconditionally
register the SOC platform device, which is currently also under the scope of this
Kconfig variable.

---
Gertjan.
