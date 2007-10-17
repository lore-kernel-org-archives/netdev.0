From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Please pull 'fixes-davem' branch of wireless-2.6
Date: Wed, 17 Oct 2007 10:53:15 -0400
Message-ID: <20071017145315.GC5744@tuxdriver.com>
References: <20071017023145.GA2848@tuxdriver.com> <200710162329.55966.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Michael Wu <flamingice@sourmilk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4505 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754895AbXJQPL7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 11:11:59 -0400
Content-Disposition: inline
In-Reply-To: <200710162329.55966.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 16, 2007 at 11:29:51PM -0400, Michael Wu wrote:
> On Tuesday 16 October 2007 22:31:46 John W. Linville wrote:
> > Bill Moss (1):
> >       mac80211: honor IW_SCAN_THIS_ESSID in siwscan ioctl
> >
> Where did this patch come from? The original patch looked nothing like this, 
> and this patch changes the behavior of siwscan incorrectly. If the interface 

"Nothing like this"?  I moved a conditional from inside a specific
case to outside the whole switch.  Let's not overstate things.

> is not STA, IBSS, or AP, scanning should not be permitted. This patch allows 
> scanning on any interface if a SSID is specified. NACK.

I refactored the patch in response to Johannes' email on 10/11 that
said "I think it should be done regardless of mode".

	http://marc.info/?l=linux-wireless&m=119209214914682&w=2

I seem to have botched the repost -- sorry about that.

Looking closer, it does seem like ieee80211_sta_req_scan may not be
robust enough to handle an inappropriate interface gracefully.  So,
let's add a patch that relocates the conditional after the switch,
and let the switch filter-out the bad interfaces for us.

Patch to follow (if I've figured-out git-send-email)...

John
-- 
John W. Linville
linville@tuxdriver.com
