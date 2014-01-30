From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Thu, 30 Jan 2014 23:05:22 +0100
Message-ID: <87bnytqg65.fsf@nemi.mork.no>
References: <20140130211816.GB3787@xanatos>
	<Pine.LNX.4.44L0.1401301630340.31548-100000@netrider.rowland.org>
	<20140130215523.GC14228@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Stern <stern@rowland.harvard.edu>,
	David Laight <David.Laight@ACULAB.COM>,
	"linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Dan Williams <dan.j.williams@intel.com>,
	"Nyman\, Mathias" <mathias.nyman@intel.com>,
	Mark Lord <mlord@pobox.com>, Freddy Xin <freddy@asix.com.tw>
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:39820 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753226AbaA3WFs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 17:05:48 -0500
In-Reply-To: <20140130215523.GC14228@xanatos> (Sarah Sharp's message of "Thu,
	30 Jan 2014 13:55:23 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sarah Sharp <sarah.a.sharp@linux.intel.com> writes:
> On Thu, Jan 30, 2014 at 04:43:54PM -0500, Alan Stern wrote:
>
>> ehci-hcd gets along okay with the restriction that each SG element=20
>> except the last has to be a multiple of the maxpacket size.  xhci-hc=
d=20
>> can relax this quite a lot, but not all the way.
>
> What does the EHCI driver do when it receives a SG list from the USB
> networking layer that violates this restriction?

The USB networking layer won't use SG with the EHCI driver.

Commit bcc48f1a7a0d4 introduced no_sg_constraint so that usbnet could
enable SG only for host controllers with no such restrictions. I.e.
currently for xHCI only.


Bj=C3=B8rn
