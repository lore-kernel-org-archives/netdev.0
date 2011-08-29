From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: BQL crap and wireless
Date: Mon, 29 Aug 2011 14:10:45 -0700
Message-ID: <CAB=NE6XrkdiZcGEDGuYe=SwLBhTm=Mt4NaPzjV9j_W-8sVosOA@mail.gmail.com>
References: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com>
 <CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	Andrew McGregor <andrewmcgr@gmail.com>,
	Matt Smith <smithm@qca.qualcomm.com>,
	Kevin Hayes <hayes@qca.qualcomm.com>,
	Dave Taht <dave.taht@gmail.com>,
	Derek Smithies <derek@indranet.co.nz>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:40078 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753838Ab1H2VLF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2011 17:11:05 -0400
In-Reply-To: <CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 29, 2011 at 2:02 PM, Luis R. Rodriguez <mcgrof@gmail.com> wrote:
> Hope this helps sum up the issue for 802.11 and what we are faced with.

I should elaborate a bit more here on ensuring people understand that
the "bufferbloat" issue assumes simply not retrying frames is a good
thing. This is incorrect. TCP's congestion algorithm is designed to
help with the network conditions, not the dynamic PHY conditions. The
dyanmic PHY conditions are handled through a slew of different means:

  * Rate control
  * Adaptive Noise Immunity effort

Rate control is addressed either in firmware or by the driver.
Typically rate control algorithms use some sort of metrics to do best
guess at what rate a frame should be transmitted at. Minstrel was the
first to say -- ahhh the hell with it, I give up and simply do trial
and error and keep using the most reliable one but keep testing
different rates as you go on. You fixate on the best one by using
EWMA.

What I was arguing early was that perhaps the same approach can be
taken for the latency issues under the assumption the resolution is
queue size and software retries. In fact this same principle might be
able to be applicable to the aggregation segment size as well.

Now, ANI is specific to hardware and does adjustments on hardware
based on some known metrics. Today we have fixed thresholds for these
but I wouldn't be surprised if taking minstrel-like guesses and doing
trial and error and EWMA based fixation would help here as well.

  Luis
