From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: use-after-free in usbnet
Date: Wed, 21 Mar 2012 10:35:22 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1203211031490.1369-100000@iolanthe.rowland.org>
References: <CACVXFVPK9vj8oqjr1SFr2MgoQn-2XoDqyb95oW+7LCHT7020Ow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, <linux-usb@vger.kernel.org>,
	Fedora Kernel Team <kernel-team@fedoraproject.org>,
	Dave Jones <davej@redhat.com>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:38490 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1030742Ab2CUOfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 10:35:23 -0400
In-Reply-To: <CACVXFVPK9vj8oqjr1SFr2MgoQn-2XoDqyb95oW+7LCHT7020Ow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Mar 2012, Ming Lei wrote:

> Looks it is a general issue about usb_hcd_unlink_urb.
> 
> Alan, how about increasing URB reference count before calling unlink1
> inside usb_hcd_unlink_urb to fix this kind of problem?

No, that won't fix the problem.  The URB could complete and be
deallocated even before usb_hcd_unlink_urb() is called, so nothing that
function can do will prevent the error.

It is the caller's responsibility to make sure that the URB does not 
get freed before usb_unlink_urb() or usb_kill_urb() returns.  We 
probably should mention this in the kerneldoc...

Alan Stern
