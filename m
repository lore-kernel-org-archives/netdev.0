From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [RFC PATCH 1/2] Hardware button support for Wireless cards:
 radiobtn
Date: Thu, 22 Jun 2006 17:55:46 +0200
Message-ID: <20060622175546.7eebebb4@griffin.suse.cz>
References: <200605251716.00742.IvDoorn@gmail.com>
	<200606041002.33696.IvDoorn@gmail.com>
	<200606041214.45999.stefan@loplof.de>
	<200606171705.59498.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stefan Rompf <stefan@loplof.de>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Vojtech Pavlik <vojtech@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:58810 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751829AbWFVPzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 11:55:48 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200606171705.59498.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 17 Jun 2006 17:05:55 +0200, Ivo van Doorn wrote:
> With this approach more buttons can be registered,
> it includes the optional field to report an update of the key status
> to the driver that registered it, and it supports for non-polling keys.

I think this is not specific to networking anymore, so it should go to
lkml. Please be sure to Cc: input devices maintainer, Dmitry Torokhov.

Regarding rfkill button, I talked about that with Vojtech Pavlik (Cc:ed)
and he suggests this solution:

- driver is responsible for turning on/off radio when the input device
  is not opened;
- when something opens the input device, it receives input events and 
  gets responsible to turn on/off the radio (by ioctl or putting the 
  network interfaces up/down).

This is of course not possible for all hardware, but it gives the most
flexibility while keeping the possibility to switch of the radio without
userspace support.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
