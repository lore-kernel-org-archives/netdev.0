From: Arnd Bergmann <arnd@linaro.org>
Subject: Re: [PATCH net-next V2 13/23] ptp: igb: convert to the 64 bit get/set time methods.
Date: Sun, 22 Mar 2015 03:40:16 +0100
Message-ID: <201503220340.16405.arnd@linaro.org>
References: <cover.1426973658.git.richardcochran@gmail.com> <c63a73eca6e75dc82990266ba2e787b58b684721.1426973658.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Baolin Wang <baolin.wang@linaro.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Chris Metcalf <cmetcalf@ezchip.com>,
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
	Stefan =?iso-8859-15?q?S=F8rensen?=
	<stefan.sorensen@spectral
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c63a73eca6e75dc82990266ba2e787b58b684721.1426973658.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 21 March 2015, Richard Cochran wrote:
> @@ -269,13 +270,13 @@ static int igb_ptp_adjtime_i210(struct ptp_clock_info *ptp, s64 delta)
>         struct igb_adapter *igb = container_of(ptp, struct igb_adapter,
>                                                ptp_caps);
>         unsigned long flags;
> -       struct timespec now, then = ns_to_timespec(delta);
> +       struct timespec64 now, then = ns_to_timespec64(delta);
>  
>         spin_lock_irqsave(&igb->tmreg_lock, flags);
>  
>         igb_ptp_read_i210(igb, &now);
> -       now = timespec_add(now, then);
> -       igb_ptp_write_i210(igb, (const struct timespec *)&now);
> +       now = timespec64_add(now, then);
> +       igb_ptp_write_i210(igb, (const struct timespec64 *)&now);
>  
>         spin_unlock_irqrestore(&igb->tmreg_lock, flags);
>  

This is one of the functions that would actually become more efficient if
the argument type gets changed to ktime_t.

	Arnd
