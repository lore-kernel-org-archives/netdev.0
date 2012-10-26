From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bas_gigaset: fix pre_reset handling
Date: Fri, 26 Oct 2012 02:20:58 -0400 (EDT)
Message-ID: <20121026.022058.1269607845663983487.davem@davemloft.net>
References: <20121024-patch-gigaset-01.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, oneukum@suse.de, hjlipp@web.de,
	gigaset307x-common@lists.sourceforge.net,
	linux-usb@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tilman@imap.cc
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121024-patch-gigaset-01.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tilman Schmidt <tilman@imap.cc>
Date: Wed, 24 Oct 2012 20:44:32 +0200

> The delayed work function int_in_work() may call usb_reset_device()
> and thus, indirectly, the driver's pre_reset method. Trying to
> cancel the work synchronously in that situation would deadlock.
> Fix by avoiding cancel_work_sync() in the pre_reset method.
> 
> If the reset was NOT initiated by int_in_work() this might cause
> int_in_work() to run after the post_reset method, with urb_int_in
> already resubmitted, so handle that case gracefully.
> 
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>

Applied, thanks.
