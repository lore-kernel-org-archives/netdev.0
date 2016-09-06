From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [RFC PATCH 1/2] macb: Add 1588 support in Cadence GEM.
Date: Tue, 6 Sep 2016 13:06:53 +0530
Message-ID: <CAFcVECJ5s_fboK5Q_etSw3APYxCNPTnX_CzZB3FsEMzK4vW6mA@mail.gmail.com>
References: <1472820817-21874-1-git-send-email-andrei.pistirica@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>, davem@davemloft.net,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        Harini Katakam <harini.katakam@xilinx.com>,
        Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
        "michals@xilinx.com" <michals@xilinx.com>,
        Anirudha Sarangi <anirudh@xilinx.com>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        alexandre.belloni@free-electrons.com, tbultel@pixelsurmer.com,
        Richard Cochran <richardcochran@gmail.com>
To: Andrei Pistirica <andrei.pistirica@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472820817-21874-1-git-send-email-andrei.pistirica@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrei,

Adding Richard Cochran for PTP.

On Fri, Sep 2, 2016 at 6:23 PM, Andrei Pistirica
<andrei.pistirica@microchip.com> wrote:
> From: Harini Katakam <harinik@xilinx.com>
>
> Cadence GEM provides a 102 bit time counter with 48 bits for seconds,
> 30 bits for nsecs and 24 bits for sub-nsecs to control 1588 timestamping.
>
> This patch does the following:
> - Registers to ptp clock framework
> - Timer initialization is done by writing time of day to the timer counter.
> - ns increment register is programmed as NSEC_PER_SEC/TSU_CLK.
>   For a 24 bit subns precision, the subns increment equals
>   remainder of (NS_PER_SEC/TSU_CLK) * (2^24).
> - HW time stamp capabilities are advertised via ethtool and macb ioctl is
>   updated accordingly.
> - Timestamps are obtained from the TX/RX PTP event/PEER registers.
>   The timestamp obtained thus is updated in skb for upper layers to access.
> - The drivers register functions with ptp to perform time and frequency
>   adjustment.
> - Time adjustment is done by writing to the 1558_ADJUST register.
>   The controller will read the delta in this register and update the timer
>   counter register. Alternatively, for large time offset adjustments,
>   the driver reads the secs and nsecs counter values, adds/subtracts the
>   delta and updates the timer counter.
> - Frequency adjustment is not directly supported by this IP.
>   addend is the initial value ns increment and similarly addendesub.
>   The ppb (parts per billion) provided is used as
>   ns_incr = addend +/- (ppb/rate).
>   Similarly the remainder of the above is used to populate subns increment.
>   In case the ppb requested is negative AND subns adjustment greater than
>   the addendsub, ns_incr is reduced by 1 and subns_incr is adjusted in
>   positive accordingly.
>
> Signed-off-by: Harini Katakam <harinik@xilinx.com>
> Signed-off-by: Andrei Pistirica <andrei.pistirica@microchip.com>
> ---
> This patch is based on original Harini's patch, implemented in a
> separate file to ease the review/maintanance and integration with
> other platforms (e.g. Zynq Ultrascale+ MPSoC).
> Feature was tested on SAMA5D2 platform using ptp4l v1.6 from linuxptp
> project and also with ptpd2 version 2.3.1. PTP was tested over
> IPv4,IPv6 and 802.3 protocols.
>
> Hariani, please let me know if you are ok with this patch, and if you
> want to be stated as author/signed-off?
>

Thanks for the patch. It seems ok. I'm making some changes on
top of this, especially in your second patch for picking RX timestamp,
since that is handled from indication in the BD for ZynqMP.

Regards,
Harini
