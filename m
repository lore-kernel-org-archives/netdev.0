From: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [RFC 13/13] USB: Disable hub-initiated LPM for
	comms devices.
Date: Fri, 18 May 2012 16:09:55 -0700
Message-ID: <20120518230955.GA4686@xanatos>
References: <cover.1337203535.git.sarah.a.sharp@linux.intel.com>
	<3c634afbbe15598cdcbf77bb9393d22ad4bfa373.1337203535.git.sarah.a.sharp@linux.intel.com>
	<4FB53054.9070309@imap.cc> <20120517173150.GE4967@xanatos>
	<4FB6CF71.7080307@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: gigaset307x-common-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org, Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Hansjoerg Lipp <hjlipp-S0/GAf8tV78@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
Return-path: <users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4FB6CF71.7080307-ZTO5kqT2PaM@public.gmane.org>
List-Unsubscribe: <http://rt2x00.serialmonkey.com/mailman/options/users_rt2x00.serialmonkey.com>,
	<mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=unsubscribe>
List-Archive: <http://rt2x00.serialmonkey.com/pipermail/users_rt2x00.serialmonkey.com>
List-Post: <mailto:users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
List-Help: <mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=help>
List-Subscribe: <http://rt2x00.serialmonkey.com/mailman/listinfo/users_rt2x00.serialmonkey.com>,
	<mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=subscribe>
Errors-To: users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org
Sender: users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, May 19, 2012 at 12:38:41AM +0200, Tilman Schmidt wrote:
> Am 17.05.2012 19:31, schrieb Sarah Sharp:
> > On Thu, May 17, 2012 at 07:07:32PM +0200, Tilman Schmidt wrote:
> >>
> >> I follow the argument for class drivers. But this patch also
> >> modifies drivers for specific existing USB 2.0 only devices
> >> which are unlikely to ever grow USB 3.0 support, such as the
> >> Gigaset ISDN driver:
> >>
> >>>  drivers/isdn/gigaset/bas-gigaset.c            |    1 +
> >>>  drivers/isdn/gigaset/usb-gigaset.c            |    1 +
> > 
> > Is there a particular reason why you think that driver is unlikely to
> > ever get USB 3.0 support?
> 
> Actually, there is. :-)
> - The USB devices driven by this driver aren't built anymore.
> - Their USB interface design is quite, um, idiosyncratic, and it's
>   pretty unlikely that anyone will reuse it. (At least I truly hope
>   no one will.)
> - Their successor models have completely different and incompatible
>   USB interfaces which this driver is unable to handle.

I see!

> >> What is the interest of setting the disable_hub_initiated_lpm
> >> flag for these?
> > 
> > It's partially to lay the foundation for anyone who wants to make a USB
> > 3.0 communications driver in the future.  They're likely to start from
> > some USB 2.0 class driver, and copy a lot of code.  If they notice that
> > flag is set in all the USB communications class drivers, they're likely
> > to set it as well.
> 
> You've got a point there.
> 
> > I'm not quite sure where the best place to provide documentation on the
> > flag is.  I've added the kernel doc comments to the structure, but maybe
> > it needs to be documented somewhere in Documentation/usb/?
> 
> Documentation/usb/power-management.txt would seem like a natural
> place. Although it appears to limit itself to "suspending" in its
> first paragraph, it does have a section "xHCI hardware link PM"
> at the end already, added by Andiry Xu on 2011-09-23.

Ok, I'll send a separate patch to add documentation here, after the 3.5
merge window.  (I just sent the pull request for the USB 3.0 LPM patches
off to Greg.)

> Hmmm, that section seems to suggest that LPM exists for USB2, too.
> Perhaps I should reconsider my attitude towards your patch.

The patchset doesn't change the USB 2.0 LPM behavior at all.  USB 2.0
doesn't have hub initiated LPM, because that would mean changing
existing USB 2.0 hub IP.  Only devices attached directly to the roothub
will be able to do USB 2.0 LPM.  Also, devices have to specifically say
they implement the USB 2.1 LPM extensions, so it's unlikely devices
supported by your driver implement USB 2.0 LPM.

Sarah Sharp
