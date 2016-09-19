From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH 1/2] ptp_clock: allow for it to be optional
Date: Mon, 19 Sep 2016 19:04:15 +0200
Message-ID: <20160919190415.26bd9343@griffin>
References: <1474257070-4255-1-git-send-email-nicolas.pitre@linaro.org>
        <1474257070-4255-2-git-send-email-nicolas.pitre@linaro.org>
        <20160919142553.3fb682ba@griffin>
        <alpine.LFD.2.20.1609190942230.9311@knanqh.ubzr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Richard Cochran <richardcochran@gmail.com>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.20.1609190942230.9311@knanqh.ubzr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Sep 2016 10:10:21 -0400 (EDT), Nicolas Pitre wrote:
> --- a/include/linux/ptp_clock_kernel.h
> +++ b/include/linux/ptp_clock_kernel.h
> @@ -207,7 +207,16 @@ int ptp_find_pin(struct ptp_clock *ptp,
>  #else
>  static inline struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
>  						   struct device *parent)
> -{ return NULL; }
> +{
> +	if (IS_MODULE(CONFIG_PTP_1588_CLOCK)) {
> +		pr_warn("%s is built-in while PTP clock subsystem is modular, "
> +			"PTP clock ignored\n", KBUILD_MODNAME);
> +	} else {
> +		pr_warn("ignoring PTP clock from %s as PTP clock subsystem "
> +			"is configured out\n", KBUILD_MODNAME);
> +	}
> +	return NULL;
> +}

I think the else part is not needed. If PTP is disabled, it is
disabled, nobody should be surprised by that. Looks good otherwise.

Thanks,

 Jiri
