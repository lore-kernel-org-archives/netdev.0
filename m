From: Luca Coelho <luca@coelho.fi>
Subject: Re: [PATCH] mac80211: fix channel switch for chanctx-based drivers
Date: Mon, 18 Aug 2014 16:59:25 +0300
Message-ID: <1408370365.20137.11.camel@dubbel>
References: <1408351816.29649.8.camel@dubbel>
	 <1408360749-10233-1-git-send-email-michal.kazior@tieto.com>
	 <CA+55aFy4X9+o3u=gPcsVfO8VHLcdzifefdjMDoH+uB0xKzym9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michal Kazior <michal.kazior@tieto.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dedo.coelho.fi ([88.198.205.34]:41883 "EHLO dedo.coelho.fi"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750924AbaHRN7k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2014 09:59:40 -0400
In-Reply-To: <CA+55aFy4X9+o3u=gPcsVfO8VHLcdzifefdjMDoH+uB0xKzym9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus,

On Mon, 2014-08-18 at 08:53 -0500, Linus Torvalds wrote:
> On Mon, Aug 18, 2014 at 6:19 AM, Michal Kazior <michal.kazior@tieto.com> wrote:
> >
> > I've verified this fix with iwlmvm & 7260.
> 
> So I'm running a kernel with this manually applied, and so far so
> good. But I don't know what actually triggered the problem, and it
> definitely didn't happen all the time, so my testing of this is
> dubious. But the patch certainly seems to match the symptoms. Thanks,

What triggers this is a "Channel Switch Announcement" on which the
access point tells the clients to move to another channel at a specified
time.  This is not very common, but some enterprise APs use it to
improve the operating radio conditions, for instance.

Previously, as a client, we would simply disconnect from the current
channel and reconnect on the new channel after the time specified by the
AP.  Now we implemented a more advanced switch where we don't lose
connectivity, but "simply" switch channels.

Hope this clarifies a bit.

--
Cheers,
Luca.
