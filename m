From: Jakub Kicinski <jakub.kicinski-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Subject: Re: [PATCHv3 wl-drv-next 1/2] add basic register-field manipulation
 macros
Date: Tue, 5 Jul 2016 12:25:38 +0100
Message-ID: <20160705122538.5ba043d9@jkicinski-Precision-T1700>
References: <1467408409-24224-1-git-send-email-jakub.kicinski@netronome.com>
	<1467408409-24224-2-git-send-email-jakub.kicinski@netronome.com>
	<063D6719AE5E284EB5DD2968C1650D6D5F4F06BF@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org" <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org" <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	"nbd-Vt+b4OUoWG0@public.gmane.org" <nbd-Vt+b4OUoWG0@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F4F06BF-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 5 Jul 2016 10:56:13 +0000, David Laight wrote:
> From: Jakub Kicinski
> > Sent: 01 July 2016 22:27
> > 
> > C bitfields are problematic and best avoided.  Developers
> > interacting with hardware registers find themselves searching
> > for easy-to-use alternatives.  Common approach is to define
> > structures or sets of macros containing mask and shift pair.
> > Operations on the register are then performed as follows:
> > 
> >  field = (reg >> shift) & mask;
> > 
> >  reg &= ~(mask << shift);
> >  reg |= (field & mask) << shift;
> > 
> > Defining shift and mask separately is tedious.  Ivo van Doorn
> > came up with an idea of computing them at compilation time
> > based on a single shifted mask (later refined by Felix) which
> > can be used like this:
> > 
> >  #define REG_FIELD 0x000ff000
> > 
> >  field = FIELD_GET(REG_FIELD, reg);
> > 
> >  reg &= ~REG_FIELD;
> >  reg |= FIELD_PUT(REG_FIELD, field);  
> 
> My problem with these sort of 'helpers' is that they make it much harder
> to read code unless you happen to know exactly what the helpers do.
> Unexpected issues (like values being sign extended) can be hard to spot.
> 
> A lot of the time you can make things simpler by not doing the shifts
> (ie define shifted constants).

I think creating a standard set of macros in a global header file is
actually helping the problems you raise.  One is much more likely to
know exactly what a common macro is doing than some driver-specific
ad hoc macro.  Common macros are also much more likely to be well
tested making "unexpected issues" less likely to appear.

Defining constants is fine in 20% of cases when you have only a small
set of meaningful values (e.g. what to do for a 8 bit delay or
priority field?)  Besides when fields are not aligned to 4 bits it's
hard to tell from the shifted value what the base was.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
