From: Borislav Petkov <bp@alien8.de>
Subject: Re: SYSFS "errors"
Date: Tue, 19 Feb 2013 14:06:26 +0100
Message-ID: <20130219130626.GE26623@pd.tnic>
References: <20130218221306.GA21493@pd.tnic>
 <20130218222618.GA21818@kroah.com>
 <20130218224405.GB21493@pd.tnic>
 <20130219070310.2cadad7a@redhat.com>
 <20130219101121.GJ23197@arwen.pp.htv.fi>
 <20130219081149.46972f56@redhat.com>
 <20130219114345.GA26623@pd.tnic>
 <20130219091610.2b746a30@redhat.com>
 <20130219123502.GD26623@pd.tnic>
 <20130219094640.2abf1a66@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: balbi@ti.com, Greg KH <gregkh@linuxfoundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>, JBottomley@parallels.com,
	linux-scsi@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Doug Thompson <dougthompson@xmission.com>,
	linux-edac@vger.kernel.org, rjw@sisk.pl, linux-pm@vger.kernel.org
To: Mauro Carvalho Chehab <mchehab@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130219094640.2abf1a66@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 19, 2013 at 09:46:40AM -0300, Mauro Carvalho Chehab wrote:
> Ah, now I see what you're meaning. That would require to dynamically
> create a per-mci DEVICE_ATTR().

Dude, look at the code, we do that already. And you're using it with
dev_attr_sdram_scrub_rate.

Simply change the permissions of the attribute before calling
device_create_file.

pseudo:

	umode_t mode = 0;

	if (mci->set...)
		mode |= S_IWUSR;

	if (mci->get...)
		mode |= S_IRUGO;


	dev_attr_sdram_scrub_rate.attr.mode = mode;

	device_create_file(&mci->dev, &dev_attr_sdram_scrub_rate);

> No, on both cases, open() will return an error (-ENOENT against -EPERM).

What if it is a shell script doing:

cat /sys/devices/system/edac/mc/mc0/sdram_scrub_rate

or similar?

Simply fixing the permissions fixes *all* possible cases.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
