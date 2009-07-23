From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Thu, 23 Jul 2009 10:28:48 -0700
Message-ID: <20090723102848.00a56ad1@nehalam>
References: <4A65EC3F.4050400@gibraltar.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>
To: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36444 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752311AbZGWR2x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2009 13:28:53 -0400
In-Reply-To: <4A65EC3F.4050400@gibraltar.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jul 2009 18:26:39 +0200
Rene Mayrhofer <rene.mayrhofer@gibraltar.at> wrote:

> Hi everybody,
> 
> [Please CC me in replies, I am not currently subscribed to this list.]
> 
> I have a fully reproducible kernel oops in the sky2 module in kernel
> 2.6.28.10. The kernel is a vanilla 2.6.28.10 (and I can't switch to
> anything newer at this time because of missing squashfs-lzma support),
> patched with PaX, netfilter-layer7, squashfs (with LZMA), and IMQ. The
> base system is a Debian Lenny with some updates from testing/unstable.
> 
> Whenever interfaces using the sky2 module (this box has 8 network
> interfaces in a 19" rack appliance) go down, the oops occurs:
> 

You could try commenting out sky2_shutdown which does the Wol
power down stuff. Maybe changing setting of Wake On Lan would
help as well.

What happens if you take interface down 'ip link set eth0 down' (or ifconfig)?

There are several different register writes in the shutdown path.
You could add code to check if a particular access is disabling
the PCI buss with:

    sky2_write(... som register...)
    BUG_ON(sky2_read16(sky2->hw, B0_CTST) == 0xffff);



-- 
