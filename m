From: Arnd Bergmann <arnd@linaro.org>
Subject: Re: [PATCH net-next V2 04/23] ptp: blackfin: convert to the 64 bit get/set time methods.
Date: Sun, 22 Mar 2015 03:28:46 +0100
Message-ID: <201503220328.46415.arnd@linaro.org>
References: <cover.1426973658.git.richardcochran@gmail.com> <d60e40f5c008cf85a764f958d5b692f167cd05ba.1426973658.git.richardcochran@gmail.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:56778 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468AbbCVC36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 22:29:58 -0400
In-Reply-To: <d60e40f5c008cf85a764f958d5b692f167cd05ba.1426973658.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 21 March 2015, Richard Cochran wrote:
> -static int bfin_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
> +static int bfin_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
>  {
>         u64 ns;
>         u32 remainder;

I think it would be good to replace the open-coded 

        ns = ts->tv_sec * 1000000000ULL;
        ns += ts->tv_nsec;

here with a call to ns_to_timespec64(), here and in other drivers that you
are already touching.

	Arnd
