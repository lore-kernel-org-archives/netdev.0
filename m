From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [RESEND][PATCH] Bluetooth: Make request workqueue freezable
Date: Tue, 19 May 2015 19:42:55 +0200
Message-ID: <1432057375.3970.4.camel@suse.com>
References: <s5hwq04zypv.wl-tiwai@suse.de>
	 <Pine.LNX.4.44L0.1505191017460.1453-100000@iolanthe.rowland.org>
	 <s5hpp5wtrrp.wl-tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alan Stern <stern@rowland.harvard.edu>,
	Laura Abbott <labbott@redhat.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Laura Abbott <labbott@fedoraproject.org>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"bluez mailin list (linux-bluetooth@vger.kernel.org)"
	<linux-bluetooth@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ming Lei <ming.lei@canonical.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	linux-usb@vger.kernel.org
To: Takashi Iwai <tiwai@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <s5hpp5wtrrp.wl-tiwai@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-05-19 at 19:13 +0200, Takashi Iwai wrote:
> At Tue, 19 May 2015 10:26:46 -0400 (EDT),
> Alan Stern wrote:
> > 
> > > > >  Of just have request_firmware()
> > > > > actually sleep until userspace is ready. Seriously, why is
> > > > > request_firmware not just sleeping for us.
> > 
> > It won't work.  The request_firmware call is part of the probe 
> > sequence, which in turn is part of the resume sequence.  Userspace 
> > doesn't start running again until the resume sequence is finished.  If 
> > request_firmware waited for userspace, it would hang.
> 
> Note that the recent request_firmware() doesn't need the user-space
> invocation (unless the fallback is explicitly enabled) but loads the

That is a dangerous approach. You cannot be sure you can do file IO.
It depends on the exact shape of the device tree.

> file directly.  And, request_firmware() for the cached data is valid
> to be called in the resume path.

Well, yes, if your data is cached in RAM, all is well. But that leads
to the same problem one step further. What must be cached?

	Regards
		Oliver
