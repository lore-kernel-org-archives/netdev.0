From: Chris Metcalf <cmetcalf@ezchip.com>
Subject: Re: [PATCH net-next V2 19/23] ptp: tilegx: convert to the 64 bit
 get/set time methods.
Date: Mon, 23 Mar 2015 13:26:22 -0400
Message-ID: <55104CBE.90603@ezchip.com>
References: <cover.1426973658.git.richardcochran@gmail.com> <8bc233b19d08308c01015936841d9be8d4441ece.1426973658.git.richardcochran@gmail.com> <551038FB.2070200@ezchip.com> <20150323165839.GA4330@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Arnd Bergmann <arnd@linaro.org>,
	Baolin Wang <baolin.wang@linaro.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Luwei Zhou <b45643@freescale.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Sonic Zhang <sonic.zhang@analog.com>,
	=?windows-1252?Q?Stefan_S=F8rensen?=
	<stefan.sorensen@spectra
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150323165839.GA4330@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/23/2015 12:58 PM, Richard Cochran wrote:
> On Mon, Mar 23, 2015 at 12:02:03PM -0400, Chris Metcalf wrote:
>> >This driver is 64-bit only.  Would it make more sense to just change
>> >the accessors from gettime/settime to gettime/settime64 and nothing
>> >else, i.e. rely on the current behavior that timespec and timespec64
>> >are the same type, and trust the compiler to fail it if somehow someone
>> >tried to build this driver into a 32-bit kernel?
> On the one hand, I think the best way would be for
> gxio_mpipe_get/set_timestamp to also take a timespec64, because it
> makes the width clear.  With a plain old timespec, you have to
> remember whether you are 64 bit or not.  However, but I couldn't tell
> if changing gxio_mpipe_get/set_timestamp would work for other callers
> or not.

If you're suggesting changing the gxio_mpipe_xxx_timespec routines
to take a timespec64, that sounds reasonable to me, particularly in
conjunction with your new gettime64 etc API.

As far as I know, the tilegx driver is the only client of those gxio
routines.

> If the driver is 64 bit only, shouldn't that be reflected in the
> Kconfig?

Well, the tilegx driver is only supported for the tilegx architecture,
which is only 64-bit for kernel-space.  It may be a bit confusing
because the actual driver is tile_net, which has separate implementations
for tilegx (64-bit) and tilepro (32-bit).  It's not immediately clear how
to make that more obvious.

> On the other hand, I wouldn't mind the change you suggest, if it were
> super obvious that the code is 64 bit only.  It was not obvious to me.

I guess that brings us back to changing the gxio_xxx APIs.

-- 
Chris Metcalf, EZChip Semiconductor
http://www.ezchip.com
