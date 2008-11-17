From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [v2,PCI] move ICHx GbE NVM write-protection from e1000e to PCI
 quirk
Date: Mon, 17 Nov 2008 12:02:32 -0800
Message-ID: <B27EBC40D200ED48A3F4CC2EBEABAE0B238BF6E9@orsmsx501.amr.corp.intel.com>
References: <20081116.191252.80669091.davem@davemloft.net>
	<4921C8B0.9060301@redhat.com> <20081117.114952.81357471.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"csnook@redhat.com" <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:25768 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751630AbYKQUCm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 15:02:42 -0500
In-Reply-To: <20081117.114952.81357471.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, no, not for every device with an NVRAM; just those LOM parts in the ICH-based family of products that has an unprotected region of NVRAM and a not-so-difficult set of steps necessary to corrupt the NVRAM by taking advantage of that.  By leaving the write-protection in the driver, the NVRAM can still be damaged before the driver loads (as seen with corruptions from ftrace in 2.6.27) or if the driver is never loaded.

Once the NVRAM is write-protected the driver cannot revoke that protection, only a system reset will do that.  The kernel command line option to disable the write protection is so that if/when a user needs to change a value in the NVRAM it can still be done.


>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Monday, November 17, 2008 11:50 AM
>To: csnook@redhat.com
>Cc: Kirsher, Jeffrey T; Allan, Bruce W; netdev@vger.kernel.org
>Subject: Re: [v2,PCI] move ICHx GbE NVM write-protection from e1000e to
>PCI quirk
>
>From: Chris Snook <csnook@redhat.com>
>Date: Mon, 17 Nov 2008 14:40:32 -0500
>
>> David Miller wrote:
>> > I'm less than thrilled with this patch so I'm not going to apply it.
>> > I mean, what are we going to do, for every single device that has a
>> > NVRAM we're going to add some PCI quirk and some new global foo_*
>> > kernel command line option to turn it off?
>> > That doesn't make any sense at all, sorry.
>>
>> Could we protect it in a PCI quirk, and optionally unprotect it in the
>driver?
>
>I think it's an overreaction, frankly.
>
>Doing it purely in the driver should be fine.
>
>Again are we going to add a NVRAM protect quirk for every PCI
>device on the planet that has a NVRAM?
>
>It's not appropriate at all.
