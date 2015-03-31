From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next V3 10/23] ptp: e1000e: convert to the 64 bit
 get/set time methods.
Date: Tue, 31 Mar 2015 23:48:15 +0200
Message-ID: <20150331214815.GA9233@localhost.localdomain>
References: <cover.1427662906.git.richardcochran@gmail.com>
 <fe1c6929e8568acbc329d75beef97ed8977eeac1.1427662907.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <fe1c6929e8568acbc329d75beef97ed8977eeac1.1427662907.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 29, 2015 at 11:12:00PM +0200, Richard Cochran wrote:

> @@ -171,11 +171,11 @@ static void e1000e_systim_overflow_work(struct =
work_struct *work)
>  	struct e1000_adapter *adapter =3D container_of(work, struct e1000_a=
dapter,
>  						     systim_overflow_work.work);
>  	struct e1000_hw *hw =3D &adapter->hw;
> -	struct timespec ts;
> +	struct timespec64 ts;
> =20
> -	adapter->ptp_clock_info.gettime(&adapter->ptp_clock_info, &ts);
> +	adapter->ptp_clock_info.gettime64(&adapter->ptp_clock_info, &ts);
> =20
> -	e_dbg("SYSTIM overflow check at %ld.%09lu\n", ts.tv_sec, ts.tv_nsec=
);
> +	e_dbg("SYSTIM overflow check at %lld.%09lu\n", ts.tv_sec, ts.tv_nse=
c);

On a 64 bit build, this triggers a new warning.

drivers/net/ethernet/intel/e1000e/ptp.c: In function =E2=80=98e1000e_sy=
stim_overflow_work=E2=80=99:
drivers/net/ethernet/intel/e1000e/ptp.c:176:2: warning: format =E2=80=98=
%lld=E2=80=99 expects argument of type =E2=80=98long long int=E2=80=99,=
 but argument 4 has type =E2=80=98__kernel_time_t=E2=80=99 [-Wformat]

On 32 bit, timespec64.tv_sec is of type 'time64_t' or '__s64'.

On 64 bit, timespec64.tv_sec is of type '__kernel_time_t' or
'__kernel_long_t' or 'long'.

How are we supposed to print that field?  With a cast?

Thanks,
Richard
