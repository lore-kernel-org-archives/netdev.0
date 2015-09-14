From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH V2] debugfs: don't assume sizeof(bool) to be 4 bytes
Date: Mon, 14 Sep 2015 09:03:48 -0700
Message-ID: <20150914160348.GA7290@kroah.com>
References: <81516fb9c662cc338b5af5b63fbbcde5374e0893.1442202447.git.viresh.kumar@linaro.org>
 <1708603.aKpYchk1pa@wuerfel>
 <20150914154708.GF32551@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, linaro-kernel@lists.linaro.org,
	"open list:NETWORKING DRIVERS WIRELESS" <linux-wireless@vger.kernel.org>,
	"moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>,
	Avri Altman <avri.altman@intel.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Jiri Slaby <jirislaby@gmail.com>,
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Mark Brown <broonie@kernel.org>, Jaroslav Kysela <perex@perex.cz>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	Kalle Valo <kvalo@qca.qualcomm.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Wang Long <long.wanglong@huawei.com>,
	Richard Fitzgerald <rf@opensource.wolfsonmicro.com>,
	Ingo Molnar <mingo@kernel.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	Davidlohr Bueso <dave@stg
To: Viresh Kumar <viresh.kumar@linaro.org>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20150914154708.GF32551@linux>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 14, 2015 at 09:17:08PM +0530, Viresh Kumar wrote:
> On 14-09-15, 17:39, Arnd Bergmann wrote:
> > On Monday 14 September 2015 09:21:54 Viresh Kumar wrote:
> > > diff --git a/drivers/acpi/ec_sys.c b/drivers/acpi/ec_sys.c
> > > index b4c216bab22b..bea8e425a8de 100644
> > > --- a/drivers/acpi/ec_sys.c
> > > +++ b/drivers/acpi/ec_sys.c
> > > @@ -128,7 +128,7 @@ static int acpi_ec_add_debugfs(struct acpi_ec *ec, unsigned int ec_device_count)
> > >  	if (!debugfs_create_x32("gpe", 0444, dev_dir, (u32 *)&first_ec->gpe))
> > >  		goto error;
> > >  	if (!debugfs_create_bool("use_global_lock", 0444, dev_dir,
> > > -				 (u32 *)&first_ec->global_lock))
> > > +				 &first_ec->global_lock))
> > >  		goto error;
> > >  
> > >  	if (write_support)
> > 
> > This one might need a separate patch that can be backported to stable, as
> > the original code is already broken on big-endian 64-bit machines:
> > global_lock is 'unsigned long'.
> 
> Hmmm, so you suggest a single patch that will do s/unsigned long/u32
> and that will be followed with this patch (almost) as is. Right?
> 
> Also, regarding the stable thing, we will surely not be able to
> backport it straight away. But we should get it backported for sure.
> 
> @Greg: What all kernel versions you want this to be backported for?

What ever ones you think it is relevant for :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
