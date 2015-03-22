From: Arnd Bergmann <arnd@linaro.org>
Subject: Re: [PATCH net-next V2 20/23] ptp: dp83640: convert to the 64 bit get/set time methods.
Date: Sun, 22 Mar 2015 03:36:31 +0100
Message-ID: <201503220336.31836.arnd@linaro.org>
References: <cover.1426973658.git.richardcochran@gmail.com> <55b6ec7c2e0c72a79762748981fad2ce2497f22d.1426973658.git.richardcochran@gmail.com>
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
In-Reply-To: <55b6ec7c2e0c72a79762748981fad2ce2497f22d.1426973658.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 21 March 2015, Richard Cochran wrote:
>         mutex_lock(&clock->extreg_lock);
>  
> -       err = tdr_write(1, phydev, ts, PTP_LOAD_CLK);
> +       err = tdr_write(1, phydev, &ts, PTP_LOAD_CLK);
>  
>         mutex_unlock(&clock->extreg_lock);

I don't see the change to the tdr_write() function that changes the 
argument from 'struct timespec ts' to 'struct timespec64 *', so this
looks wrong to me.

	Arnd
