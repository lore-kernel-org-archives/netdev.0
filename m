From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC/RFT PATCH 2/2] rtk_btusb: A new driver for the Bluetooth
 portion of the Realtek RTL8723AE chip
Date: Fri, 19 Apr 2013 10:23:09 +0300
Message-ID: <20130419072309.GB3214@x220>
References: <1365469068-4548-1-git-send-email-Larry.Finger@lwfinger.net>
 <1365469068-4548-3-git-send-email-Larry.Finger@lwfinger.net>
 <20130418222221.GA15279@joana>
 <51709E57.7020402@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	champion_chen-kXabqFNEczNtrwSWzY7KCg@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51709E57.7020402-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Larry,

On Thu, Apr 18, 2013, Larry Finger wrote:
> On 04/18/2013 05:22 PM, Gustavo Padovan wrote:
> >We recently added a setup callback to btusb to run device specific
> >initialization, take a look in bluetooth-next to check how that can help you
> >avoid duplicate a lot of code.
> 
> Thanks for the tip. I knew something was in the planning stage.
> 
> Is there any documentation on using the new facility?

Not really, but you can take a look at the "Bluetooth: Add support for
Intel Bluetooth device [[8087:07dc]" patch that's currently going
through some feedback rounds on linux-bluetooth. It's one of the first
users of this new API.

Basically what you have is the new setup() callback for HCI drivers and
then a new __hci_cmd_sync() function that can be used from within the
setup() callback to synchronously send whatever HCI commands you need to
send before proceeding with the normal HCI init sequence within the HCI
core.

To my understanding Marcel has planned to move the vendor specific btusb
routines into their own files in the long run (I believe he's used a
term "mini driver" for this) but for now the changes are expected to go
to the main btusb.c file.

Johan
