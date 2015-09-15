From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [PATCH V3 2/2] debugfs: don't assume sizeof(bool) to be 4 bytes
Date: Tue, 15 Sep 2015 19:42:08 +0530
Message-ID: <20150915141208.GK6350@linux>
References: <9b705747a138c96c26faee5218f7b47403195b28.1442305897.git.viresh.kumar@linaro.org>
 <27d37898b4be6b9b9f31b90135f8206ca079a868.1442305897.git.viresh.kumar@linaro.org>
 <20150915100454.70dcc04d@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@linuxfoundation.org, linaro-kernel@lists.linaro.org,
	Rafael Wysocki <rjw@rjwysocki.net>, sboyd@codeaurora.org,
	arnd@arndb.de, Mark Brown <broonie@kernel.org>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	"moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Arik Nemtsov <arik@wizery.com>,
	"open list:QUALCOMM ATHEROS ATH10K WIRELESS DRIVER" <ath10k@lists.infradead.org>,
	"open list:QUALCOMM ATHEROS ATH9K WIRELESS DRIVER" <ath9k-devel@lists.ath9k.org>,
	Avri Altman <avri.altman@intel.com>,
	"open list:B43 WIRELESS DRIVER" <b43-dev@lists.infradead.org>,
	Borislav Petkov <bp@alien8.de>,
	Brian Silverman <bsilver16384@gmail.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Charles Keepax <ckeepax@opensourc
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20150915100454.70dcc04d@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 15-09-15, 10:04, Steven Rostedt wrote:
> On Tue, 15 Sep 2015 14:04:59 +0530
> Viresh Kumar <viresh.kumar@linaro.org> wrote:
> 
> > diff --git a/drivers/acpi/ec.c b/drivers/acpi/ec.c
> > index 2614a839c60d..f11e17ad7834 100644
> > --- a/drivers/acpi/ec.c
> > +++ b/drivers/acpi/ec.c
> > @@ -1237,7 +1237,7 @@ ec_parse_device(acpi_handle handle, u32 Level, void *context, void **retval)
> >  	/* Use the global lock for all EC transactions? */
> >  	tmp = 0;
> >  	acpi_evaluate_integer(handle, "_GLK", NULL, &tmp);
> > -	ec->global_lock = tmp;
> > +	ec->global_lock = !!tmp;
> 
> BTW, the above is equivalent if global_lock is of type bool.

Ah, yes. Thanks for letting me know (I just testedit as well).

But will it look sane enough to set a boolean to anything apart from
true/false or 1/0? Yes, it will always be set to 0/1 only, but still..

-- 
viresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
