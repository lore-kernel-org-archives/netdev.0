From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: SYSFS "errors"
Date: Mon, 18 Feb 2013 14:26:18 -0800
Message-ID: <20130218222618.GA21818@kroah.com>
References: <20130218155215.GB2663@arwen.pp.htv.fi>
 <20130218171334.GA31329@kroah.com>
 <20130218172700.GH2663@arwen.pp.htv.fi>
 <20130218174916.GA2070@kroah.com>
 <20130218184633.GC10755@arwen.pp.htv.fi>
 <20130218164638.7cb53baa@redhat.com>
 <20130218200542.GB20137@arwen.pp.htv.fi>
 <20130218184742.5a4c3c06@redhat.com>
 <20130218215434.GB16794@kroah.com>
 <20130218221306.GA21493@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Borislav Petkov <bp@alien8.de>,
	Mauro Carvalho Chehab <mchehab@redhat.com>, balbi@ti.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>, JBottomley@parallels.com,
	linux-scsi@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Doug Thompson <dougthompson@xmission.com>,
	linux-edac@vger.kernel.org, rjw@sisk.pl, linux-pm@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130218221306.GA21493@pd.tnic>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 18, 2013 at 11:13:06PM +0100, Borislav Petkov wrote:
> On Mon, Feb 18, 2013 at 01:54:34PM -0800, Greg KH wrote:
> > Because sysfs is "one value per file" the lack of a file showing up
> > shouldn't cause any userspace tools any problems, that is why we did
> > things this way.
> >
> > But, of course, userspace programmers do know how to mess things up...
> 
> How about what I proposed earlier to Felipe:
> 
> --
> diff --git a/drivers/edac/edac_mc_sysfs.c b/drivers/edac/edac_mc_sysfs.c
> index 0ca1ca71157f..d2eef76d1d46 100644
> --- a/drivers/edac/edac_mc_sysfs.c
> +++ b/drivers/edac/edac_mc_sysfs.c
> @@ -704,7 +704,7 @@ static ssize_t mci_sdram_scrub_rate_show(struct device *dev,
>  	int bandwidth = 0;
>  
>  	if (!mci->get_sdram_scrub_rate)
> -		return -ENODEV;
> +		return sprintf(data, "N/A");
>  
>  	bandwidth = mci->get_sdram_scrub_rate(mci);
>  	if (bandwidth < 0) {
> 
> --
> 
> Would that hurt the sysfs policy? In this case we *can* read the file
> and it correctly tells us that scrub rate reading is not supported
> instead of having a number there.
> 
> Hmm.

I don't know, it depends on if userspace can handle this properly or
not.  What tools rely on this sysfs file?  WHat happens when they get a
non-number in the file?

thanks,

greg k-h
