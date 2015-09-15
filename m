From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH V3 2/2] debugfs: don't assume sizeof(bool) to be 4 bytes
Date: Tue, 15 Sep 2015 10:04:54 -0400
Message-ID: <20150915100454.70dcc04d@gandalf.local.home>
References: <9b705747a138c96c26faee5218f7b47403195b28.1442305897.git.viresh.kumar@linaro.org>
	<27d37898b4be6b9b9f31b90135f8206ca079a868.1442305897.git.viresh.kumar@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, linaro-kernel@lists.linaro.org, Rafael
 Wysocki <rjw@rjwysocki.net>, sboyd@codeaurora.org, arnd@arndb.de, Mark
 Brown <broonie@kernel.org>, Akinobu Mita <akinobu.mita@gmail.com>,
 Alexander Duyck <alexander.h.duyck@redhat.com>, alsa-devel@alsa-project.org
 (moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM...), Andrew
 Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>,
 Arik Nemtsov <arik@wizery.com>, ath10k@lists.infradead.org (open
 list:QUALCOMM ATHEROS ATH10K WIRELESS DRIVER), ath9k-devel@lists.ath9k.org
 (open list:QUALCOMM ATHEROS ATH9K WIRELESS DRIVER), Avri Altman
 <avri.altman@intel.com>, b43-dev@lists.infradead.org (open list:B43
 WIRELESS DRIVER), Borislav Petkov <bp@alien8.de>, Brian Silverman
 <bsilver16384@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>,
 Charles Keepax <ckeepax@opensource.wolfsonmic
To: Viresh Kumar <viresh.kumar@linaro.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <27d37898b4be6b9b9f31b90135f8206ca079a868.1442305897.git.viresh.kumar@linaro.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Sep 2015 14:04:59 +0530
Viresh Kumar <viresh.kumar@linaro.org> wrote:

> diff --git a/drivers/acpi/ec.c b/drivers/acpi/ec.c
> index 2614a839c60d..f11e17ad7834 100644
> --- a/drivers/acpi/ec.c
> +++ b/drivers/acpi/ec.c
> @@ -1237,7 +1237,7 @@ ec_parse_device(acpi_handle handle, u32 Level, void *context, void **retval)
>  	/* Use the global lock for all EC transactions? */
>  	tmp = 0;
>  	acpi_evaluate_integer(handle, "_GLK", NULL, &tmp);
> -	ec->global_lock = tmp;
> +	ec->global_lock = !!tmp;

BTW, the above is equivalent if global_lock is of type bool.

-- Steve

>  	ec->handle = handle;
>  	return AE_CTRL_TERMINATE;
>  }
> diff --git a/drivers/acpi/internal.h b/drivers/acpi/internal.h
> index 9db196de003c..5a72e2b140fc 100644
> --- a/drivers/acpi/internal.h
> +++ b/drivers/acpi/internal.h
> @@ -138,7 +138,7 @@ struct acpi_ec {
>  	unsigned long gpe;
>  	unsigned long command_addr;
>  	unsigned long data_addr;
> -	u32 global_lock;
> +	bool global_lock;
>  	unsigned long flags;
>  	unsigned long reference_count;
>  	struct mutex mutex;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
