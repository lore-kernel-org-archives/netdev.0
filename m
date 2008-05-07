From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4][MAC80211]: Fix GFP_KERNEL allocation under read
 lock.
Date: Tue, 06 May 2008 22:59:50 -0700 (PDT)
Message-ID: <20080506.225950.181623233.davem@davemloft.net>
References: <4820997E.1070305@openvz.org>
	<20080506.134047.86330538.davem@davemloft.net>
	<4821442D.8010801@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@axxeo.de, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55729
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751893AbYEGF74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 01:59:56 -0400
In-Reply-To: <4821442D.8010801@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 07 May 2008 09:54:53 +0400

> David Miller wrote:
> > The whole reason we made kfree allow NULL points is so that
> > checks for it would be ommitted at kfree calls sides, whether
> > they be direct or indirect.
> 
> Hm... I really thought that this check in kfree is just for sanity 
> against some 3rd part code. But why kmem_cache_free() is not such then?

That's not what the check was added for.

If you look in the history, there are lots of changes that
are of the form "don't check for NULL, kfree() does that"
and it decreases kernel text size.  That was why the check
was added to kfree(), so we could do that.

There have been some discussions about kmem_cache_free() NULL
checks, but that tends to keep getting stalled in the mud
for whatever reason.

Whether you should resubmit your patch is up to the wireless
folks :-)
