From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH v2] r8152: fix lockup when runtime PM is enabled
Date: Wed, 23 Dec 2015 09:20:13 +0100
Message-ID: <1450858813.6437.2.camel@suse.de>
References: <1449573462-28417-1-git-send-email-peter@lekensteyn.nl>
	 <0835B3720019904CB8F7AA43166CEEB2F8DAD9@RTITMBSV03.realtek.com.tw>
	 <20151208143305.GB18728@al>
	 <0835B3720019904CB8F7AA43166CEEB2F94D11@RTITMBSV03.realtek.com.tw>
	 <1450782082.8824.23.camel@suse.com>
	 <0835B3720019904CB8F7AA43166CEEB2F94FFF@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2F94FFF@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-12-23 at 03:31 +0000, Hayes Wang wrote:
> Oliver Neukum [mailto:oneukum@suse.com]
> [...]
> > It is clear to me that you cannot get away with using the same operation
> > for resume() and reset_resume() in your driver. It is fundamentally
> > impossible. Firmware cannot fix it.
> 
> I would think how to fix it.
> 
> > Sorry for the length of the explanation.
> 
> Thanks for your response. I have some questions. What are the flows when
> the system resume follows a system suspend which follows a autosuspend?
> Are they as following?
> 
> 1. suspend() with PMSG_IS_AUTO for autosuspned.
> 2. suspend() for system suspend.
> 3. resume() for system resume.
> 
> And, should the device exist autosuspend before (2)? 

No, step (2) does not exist. Calls to suspend() and [reset_]resume()
always balance. Usually a driver shouldn't care about system suspend.
The way the driver is currently coded will also fail for Port-Power Off.

	Regards
		Oliver
