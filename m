From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/2] usbnet: increase URB reference count before
 usb_unlink_urb
Date: Thu, 22 Mar 2012 07:35:53 -0700
Message-ID: <20120322143553.GC19835@kroah.com>
References: <1332422538-6597-1-git-send-email-tom.leiming@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, stable@kernel.org,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oliver@neukum.org>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:33416 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757268Ab2CVOf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 10:35:58 -0400
Received: by gghe5 with SMTP id e5so1789679ggh.19
        for <netdev@vger.kernel.org>; Thu, 22 Mar 2012 07:35:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1332422538-6597-1-git-send-email-tom.leiming@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 22, 2012 at 09:22:18PM +0800, Ming Lei wrote:
> Commit 4231d47e6fe69f061f96c98c30eaf9fb4c14b96d(net/usbnet: avoid
> recursive locking in usbnet_stop()) fixes the recursive locking
> problem by releasing the skb queue lock, but it makes usb_unlink_urb
> racing with defer_bh, and the URB to being unlinked may be freed before
> or during calling usb_unlink_urb, so use-after-free problem may be
> triggerd inside usb_unlink_urb.
> 
> The patch fixes the use-after-free problem by increasing URB
> reference count with skb queue lock held before calling
> usb_unlink_urb, so the URB won't be freed until return from
> usb_unlink_urb.
> 
> Cc: stable@kernel.org
> Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> Cc: Alan Stern <stern@rowland.harvard.edu>
> Cc: Oliver Neukum <oliver@neukum.org>
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Ming Lei <tom.leiming@gmail.com>

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
