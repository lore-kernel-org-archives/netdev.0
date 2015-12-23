From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH v2] r8152: fix lockup when runtime PM is enabled
Date: Wed, 23 Dec 2015 11:45:58 +0100
Message-ID: <1450867558.6437.10.camel@suse.com>
References: <1449573462-28417-1-git-send-email-peter@lekensteyn.nl>
	 <0835B3720019904CB8F7AA43166CEEB2F8DAD9@RTITMBSV03.realtek.com.tw>
	 <20151208143305.GB18728@al>
	 <0835B3720019904CB8F7AA43166CEEB2F94D11@RTITMBSV03.realtek.com.tw>
	 <1450782082.8824.23.camel@suse.com>
	 <0835B3720019904CB8F7AA43166CEEB2F94FFF@RTITMBSV03.realtek.com.tw>
	 <1450858813.6437.2.camel@suse.de>
	 <0835B3720019904CB8F7AA43166CEEB2F9547E@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"peter@lekensteyn.nl" <peter@lekensteyn.nl>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2F9547E@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-12-23 at 09:20 +0000, Hayes Wang wrote:
> Oliver Neukum [mailto:oneukum@suse.de]
> > Sent: Wednesday, December 23, 2015 4:20 PM
> [...]
> > No, step (2) does not exist. Calls to suspend() and [reset_]resume()
> > always balance. Usually a driver shouldn't care about system suspend.
> > The way the driver is currently coded will also fail for Port-Power Off.
> 
> It is different with Windows. The Windows would resume the device before
> system suspend, if the system suspend follows the autosuspend.
> 
> Would this be a problem? After system suspend, the device may wake up
> the system when receiving any packet, not only magic packet. The wake
> events are different for system suspend and autosuspend. However, I
> couldn't change the wake event, because the autosuspend occurs first,
> and the suspend() is only called once.

That is indeed a problem and I need to think a bit about finding
a good solution. If you are happy with an inelegant solution, you can
use a pm_notifier, which will tell you that the system is going
to suspend. This is documented:

https://www.kernel.org/doc/Documentation/power/notifiers.txt

	HTH
		Oliver
