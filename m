From: Alan Jenkins <sourcejedi.lkml@googlemail.com>
Subject: Re: [PATCH 2/7 v3] initdev:kernel:USB init device discovery
	notification
Date: Fri, 7 Aug 2009 18:17:51 +0100
Message-ID: <9b2b86520908071017h606e595fr4488d6ff61cb337c@mail.gmail.com>
References: <9b2b86520908070832p2d1658b0t8b1d89d1a034bb9a@mail.gmail.com>
	 <Pine.LNX.4.44L0.0908071142260.3063-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David VomLehn <dvomlehn@cisco.com>, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, linux-usb@vger.kernel.org,
	greg@kroah.com, linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754455AbZHGRRy@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.0908071142260.3063-100000@iolanthe.rowland.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/7/09, Alan Stern <stern@rowland.harvard.edu> wrote:
> On Fri, 7 Aug 2009, Alan Jenkins wrote:
>
>> > +/* The mask of possible USB boot devices depends on what drivers and
>> > + * options have been configured into the kernel.  There are too many
>> > + * USB network config options to list here, so just assume it is always
>> > + * possible to have a USB network device.
>> > + */
>>
>> That could be fixed though.  Make the "USB Network Adaptors" menu into
>> an option.  Then you just have e.g. "CONFIG_NETDEV_USB", plus the two
>> class devices outside the menu (CONFIG_USB_ACM and CONFIG_USB_WDM).

Oops, scratch WDM.  It doesn't actually provide a network device
(otherwise it would depend on NET).

> That could be done.  It might even meet with the approval of the
> networking maintainer, independent of this patch series.
>
> But what if somebody adds yet another networking class driver outside
> the menu?

Hmm.

Ok, how about a single (hidden) USB_HAS_NETDEV.  NETDEV_USB and
USB_ACM select USB_HAS_NETDEV.

Textual juxtaposition or simple copy+paste inside class/Kconfig should
help it get picked up.  And I'd add a comment pointing the bewildered
to the definition of usb_initdev_mask.

I'll write a patch for your inspection this evening.

Alan
