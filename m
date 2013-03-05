From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH 0/7] USB: don't recover device if suspend fails in system sleep
Date: Tue, 05 Mar 2013 13:50:35 +0100
Message-ID: <3703451.5FViJ58GpZ@linux-5eaq.site>
References: <1362456103-24956-1-git-send-email-ming.lei@canonical.com> <87fw0aqqel.fsf@nemi.mork.no> <CACVXFVM=PcxTLb1-Bo-11Lz0FzthQJTRKt5=sn6W85K9p8xE4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <CACVXFVM=PcxTLb1-Bo-11Lz0FzthQJTRKt5=sn6W85K9p8xE4A@mail.gmail.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 05 March 2013 18:55:42 Ming Lei wrote:
> > All these drivers suspend in multiple steps, where each step can
> > fail. If a later step fails then they revert any previously successful
> > step before returning the failure, thereby ensuring that the
> > device/driver state when suspend returns is consistently either
> > suspended or resumed.
> 
> IMO, for autosuspend, that is right, but it is not for system suspend,
> and the driver's suspend callback can't return in resumed state
> because the USB core will ignore the failure return value and force
> to suspend the device.

It seems to me that in this case you just need to make sure that
suspend() not fail for system suspend. Or revisit the decision to
ignore failures.
In other words, if we don't handle errors, there must be no errors,
otherwise it doesn't matter what we do in the error case. We'd leave
the problem to generic layers.

Furthermore there is a small chance that although the device tree
is walked, teh system suspend fails for another later reason that
is not ignored. In that case the drivers need to do error recovery,
albeit in resume().

	Regards
		Oliver

