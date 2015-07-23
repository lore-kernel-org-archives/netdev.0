From: Oliver Neukum <oneukum@suse.com>
Subject: Re: Several races in "usbnet" module (kernel 4.1.x)
Date: Thu, 23 Jul 2015 11:15:52 +0200
Message-ID: <1437642952.4377.10.camel@suse.com>
References: <55AD3A41.2040100@rosalab.ru>
	 <1437488529.3823.16.camel@suse.com> <55AFE210.7030104@rosalab.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55AFE210.7030104@rosalab.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-07-22 at 21:33 +0300, Eugene Shatokhin wrote:
> The following part is not necessary, I think. usbnet_bh() does not
> touch 
> EVENT_NO_RUNTIME_PM bit explicitly and these bit operations are
> atomic 
> w.r.t. each other.
> 
> > +     mpn |= !test_and_clear_bit(EVENT_NO_RUNTIME_PM, &dev->flags);
> > +     /* in case the bh reset a flag */

Yes, they are atomic w.r.t. each other. And that limitation worries me.

I am considering architectures which do atomic operations with
spinlocks. And this code mixes another operation into it. Can
this happen?

CPU A				CPU B

take lock
read old value
				set value to 0
clear bit
write back changed value
release lock

	Regards
		Oliver
