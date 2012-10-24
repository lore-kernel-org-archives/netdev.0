From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH v2 2/6] PM / Runtime: introduce pm_runtime_set_memalloc_noio()
Date: Wed, 24 Oct 2012 10:06:36 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7060@saturn3.aculab.com>
References: <CACVXFVMmszZWHaeNS6LSG4nHR4wWBLwM_BvynRwUW8X=nO+JWA@mail.gmail.com><Pine.LNX.4.44L0.1210231022230.1635-100000@iolanthe.rowland.org> <CACVXFVN+=XH_f5BmRkXeagTNowz0o0-Pd7GcxCneO0FSq8xqEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, "Oliver Neukum" <oneukum@suse.de>,
	"Minchan Kim" <minchan@kernel.org>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, "Jens Axboe" <axboe@kernel.dk>,
	"David S. Miller" <davem@davemloft.net>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<linux-pm@vger.kernel.org>, <linux-mm@kvack.org>
To: "Ming Lei" <ming.lei@canonical.com>,
	"Alan Stern" <stern@rowland.harvard.edu>
Return-path: <linux-pm-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <CACVXFVN+=XH_f5BmRkXeagTNowz0o0-Pd7GcxCneO0FSq8xqEw@mail.gmail.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Looks the problem is worse than above, not only bitfields are affected, the
> adjacent fields might be involved too, see:
> 
>            http://lwn.net/Articles/478657/

Not mentioned in there is that even with x86/amd64 given
a struct with the following adjacent fields:
	char a;
	char b;
	char c;
then foo->b |= 0x80; might do a 32bit RMW cycle.
This will (well might - but probably does) happen
if compiled to a 'BTS' instruction.
The x86 instruction set docs are actually unclear
as to whether the 32bit cycle might even be misaligned!
amd64 might do a 64bit cycle (not checked the docs).

	David



