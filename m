From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Thu, 30 Jan 2014 16:39:34 -0500
Message-ID: <52EAC696.6050708@pobox.com>
References: <20140130211816.GB3787@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Dan Williams <dan.j.williams@intel.com>,
	"Nyman, Mathias" <mathias.nyman@intel.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Freddy Xin <freddy@asix.com.tw>
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a-pb-sasl-quonix.pobox.com ([208.72.237.25]:32775 "EHLO
	sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118AbaA3Vji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 16:39:38 -0500
In-Reply-To: <20140130211816.GB3787@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14-01-30 04:18 PM, Sarah Sharp wrote:
>
> Let's do this fix the right way, instead of wall papering over the
> issue.  Here's what we should do:
> 
> 1. Disable scatter-gather for the ax88179_178a driver when it's under an
>    xHCI host.
> 
> 2. Revert the following commits:
>    f2d9b991c549 xhci: Set scatter-gather limit to avoid failed block writes.
>    d6c9ea9069af xhci: Avoid infinite loop when sg urb requires too many trbs
>    35773dac5f86 usb: xhci: Link TRB must not occur within a USB payload burst
> 
> 3. Dan and Mathias can work together to come up with an overall plan to
>    change the xHCI driver architecture to be fully compliant with the TD
>    fragment rules.  That can be done over the next few kernel releases.
> 
> The end result is that we don't destabilize storage or break userspace
> USB drivers, we don't break people's xHCI host controllers,
> the ax88179_178a USB ethernet devices still work under xHCI (a bit with
> worse performance), and other USB ethernet devices still get the
> performance improvement introduced in 3.12.


Performance before 3.12/3.13 was not all that bad either.
My ax88179 dongle (yes, that one, using ax88179_178a.ko)
manages very close to 1gbit/sec throughput even without SG,
and without a huge cpu tax either.

SG done Right will make it better eventually.  I can wait.

Cheers
-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
