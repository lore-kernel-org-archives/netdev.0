From: Chris Metcalf <cmetcalf@ezchip.com>
Subject: Re: [PATCH net-next V2 19/23] ptp: tilegx: convert to the 64 bit
 get/set time methods.
Date: Mon, 23 Mar 2015 12:02:03 -0400
Message-ID: <551038FB.2070200@ezchip.com>
References: <cover.1426973658.git.richardcochran@gmail.com> <8bc233b19d08308c01015936841d9be8d4441ece.1426973658.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	"Ariel Elior" <ariel.elior@qlogic.com>,
	Arnd Bergmann <arnd@linaro.org>,
	Baolin Wang <baolin.wang@linaro.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"David Miller" <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	"Giuseppe Cavallaro" <peppe.cavallaro@st.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	"Luwei Zhou" <b45643@freescale.com>,
	Matthew Vick <matthew.vick@intel.com>,
	"Michael Chan" <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Sonic Zhang <sonic.zhang@analog.com>,
	=?windows-1252?Q?Stefan_S=F8rensen?=
	<stefan.sorensen@spectralink.com>,
	Thoma
To: Richard Cochran <richardcochran@gmail.com>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8bc233b19d08308c01015936841d9be8d4441ece.1426973658.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/21/2015 05:39 PM, Richard Cochran wrote:
> This driver calls code (via gxio_mpipe_get/set_timestamp) that makes
> the assumption that the tv_sec field is 64 bits wide.  So apparently
> this driver is 64 bit only.  So maybe this driver and device are ready
> for 2038, but maybe not.
>
> Not even compile tested.
>
> Signed-off-by: Richard Cochran<richardcochran@gmail.com>

This driver is 64-bit only.  Would it make more sense to just change
the accessors from gettime/settime to gettime/settime64 and nothing
else, i.e. rely on the current behavior that timespec and timespec64
are the same type, and trust the compiler to fail it if somehow someone
tried to build this driver into a 32-bit kernel?

In any case, if you think it's better as-is, you can certainly have my

Acked-by: Chris Metcalf <cmetcalf@ezchip.com>

-- 
Chris Metcalf, EZChip Semiconductor
http://www.ezchip.com
