From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Thu, 8 Mar 2007 10:49:54 -0800
Message-ID: <20070308184954.GA24485@bougret.hpl.hp.com>
References: <1173144447.15891.93.camel@johannes.berg> <20070306171316.GA19669@bougret.hpl.hp.com> <200703061943.07350.mb@bu3sch.de> <20070307020310.GA20466@bougret.hpl.hp.com> <1173364747.14001.7.camel@johannes.berg>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>, linux-wireless@vger.kernel.org,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	Dan Williams <dcbw@redhat.com>,
	Jouni Malinen <jkm@devicescape.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:59761 "EHLO madara.hpl.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933038AbXCHSvr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 13:51:47 -0500
Content-Disposition: inline
In-Reply-To: <1173364747.14001.7.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 08, 2007 at 03:39:07PM +0100, Johannes Berg wrote:
> On Tue, 2007-03-06 at 18:03 -0800, Jean Tourrilhes wrote:
> 
> > 	Ok, please check the patch attached. I don't have a box to
> > test that on, and on my 32 bit kernel it is not even compiled, but I
> > believe I got everything all right.
> 
> Don't I wish it was that easy... Granted, that does seem to fix the
> issue with iw_point but that's not the only thing that's broken. Here's
> the next thing, I think this only happens after applying that patch,
> without it probably just craps out earlier. Same thing happens with
> iwevent (and maybe other things too.)
> 
> Enabling debugging in wireless tools yields (on my 64-bit kernel with
> 32-bit userland):
> # LD_LIBRARY_PATH=.  ./iwlist wlan0 scan
> Scan result 4096
> [00:18:8B:15:50:8A:35:E0:00:01:00:C0:02:E1:B8:0E:C0:00:00:00:50:8A:35:F0:00:19:8B:1B:50:8A:35:E0:00:09:00:01:50:8A:35:F0:47:6F:6C:6F:73:4E:65:74:7A:00:18:8B:01:50:8A:35:E0:49:45:45:45:20:38:30:32:2E:31:31:62:67:00:35:F0:00:0C:8B:07:50:8A:35:E0:00:00:00:03:00:10:8B:05:50:8A:35:E0:00:00:00:07:00:00:00:32:00:10:8B:2B:50:8A:35:E0:00:00:08:00:67:00:35:F0:00:70:8B:21:50:8A:35:E0:00:0F:42:40:00:00:00:32:00:1E:84:80:00:00:00:32:00:53:EC:60:00:00:00:32:00:5B:8D:80:00:00:00:32:00:89:54:40:00:00:00:32:00:A7:D8:C0:00:00:00:<lots more zeroes>
> wlan0     Scan completed : 
> DBG - stream->current = 0x10019008, stream->value = (nil), stream->end = 0x1001a008
> DBG - iwe->cmd = 0x8B15, iwe->len = 24
> 
>                          ^^^^^^^^^^^^^ that's already bogus

	Ok, now I get it. It's an alignement issue, the kernel align
struct to 64 bit boundary, whereas the userspace expect it to 32 bit
boundary. Pretty nasty.
	A proper fix would involve forcing the alignement in the
kernel. Unfortunately, that would break 64bit->64bit configs. I think
I can build a workaround for this in iwlib.

	Thanks for the detailed bug report !

	Jean
