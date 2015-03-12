From: Eliad Peller <eliad@wizery.com>
Subject: Re: wl18xx: Bad format for rx_frames_per_rates in debugfs?
Date: Thu, 12 Mar 2015 15:16:31 +0200
Message-ID: <CAB3XZEfKCmfO_AojsGiCn+7ZE3eNiYcsuuDzHSb++7-qHF7p7A@mail.gmail.com>
References: <55018919.3050902@m4x.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Kalle Valo <kvalo@codeaurora.org>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55018919.3050902@m4x.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 12, 2015 at 2:39 PM, Nicolas Iooss
<nicolas.iooss_linux@m4x.org> wrote:
> Hello,
>
> While adding __printf attributes to several functions in the kernel, I
> got a surprising gcc warning in drivers/net/wireless/ti/wl18xx/debugfs.c
> about "format '%u' expects argument of type 'unsigned int', but argument
> 5 has type 'u32 *'".
>
> Indeed it seems that commit c5d94169e818 ("wl18xx: use new fw stats
> structures") [1] introduced an array field "u32 rx_frames_per_rates[50]"
> in struct wl18xx_acx_rx_rate_stat but is using
> WL18XX_DEBUGFS_FWSTATS_FILE(rx_rate, rx_frames_per_rates, "%u"); instead
> of something like WL18XX_DEBUGFS_FWSTATS_FILE_ARRAY(rx_rate,
> rx_frames_per_rates, 50); for displaying this value.  So I believe that
> currently the rx_rate entry in debugfs contains a kernel pointer instead
> of the actual data.  As I don't have the hardware to test I can't be
> sure of it.
>
> Is this a real bug which needs to be fixed or something weird I haven't
> understood yet?
>
yes, seems like a bug.

Eliad.
