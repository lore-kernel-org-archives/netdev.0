From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next V3 13/23] ptp: igb: convert to the 64 bit
 get/set time methods.
Date: Tue, 31 Mar 2015 23:53:17 +0200
Message-ID: <20150331215317.GA9339@localhost.localdomain>
References: <cover.1427662906.git.richardcochran@gmail.com>
 <67fa71b28f96b222c8027b49efee4144b3754bf7.1427662907.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Arnd Bergmann <arnd@linaro.org>,
	Baolin Wang <baolin.wang@linaro.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Chris Metcalf <cmetcalf@ezchip.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Luwei Zhou <b45643@freescale.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rayagond K <rayagond@vayavyalabs.com>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Sonic Zhang
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:36239 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752973AbbCaVxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 17:53:23 -0400
Content-Disposition: inline
In-Reply-To: <67fa71b28f96b222c8027b49efee4144b3754bf7.1427662907.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 29, 2015 at 11:12:03PM +0200, Richard Cochran wrote:

> @@ -627,11 +628,11 @@ static void igb_ptp_overflow_check(struct work_struct *work)
>  {
>  	struct igb_adapter *igb =
>  		container_of(work, struct igb_adapter, ptp_overflow_work.work);
> -	struct timespec ts;
> +	struct timespec64 ts;
>  
> -	igb->ptp_caps.gettime(&igb->ptp_caps, &ts);
> +	igb->ptp_caps.gettime64(&igb->ptp_caps, &ts);
>  
> -	pr_debug("igb overflow check at %ld.%09lu\n", ts.tv_sec, ts.tv_nsec);
> +	pr_debug("igb overflow check at %lld.%09lu\n", ts.tv_sec, ts.tv_nsec);

For a 64 bit build, this produces the same warning as e1000e.

What is the best way to deal with this warning?

Thanks,
Richard
