From: Josh Lehan <linux@krellan.com>
Subject: Re: Skipping past TCP lost packet in userspace
Date: Thu, 30 Jun 2011 01:38:12 -0700
Message-ID: <4E0C35F4.6050901@krellan.com>
References: <4DE44218.4070306@krellan.com>	 <BANLkTinKORbHHZ7dAqfiFOg5rqB77DcJY8D7AxmP-xwhwmOgGg@mail.gmail.com>	 <4DE5F3E3.2080609@krellan.com> <1306949723.8149.2202.camel@tardy> <4E04A609.7010206@fandm.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Janardhan Iyengar <jana.iyengar@gmail.com>, rick.jones2@hp.com,
	Josh Lehan <linux@krellan.com>,
	Yuchung Cheng <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>, Bryan Ford <bryan.ford@yale.edu>
To: janardhan.iyengar@fandm.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from server4.hostdango.com ([70.86.37.74]:32934 "EHLO
	server4.hostdango.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754126Ab1F3IiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 04:38:17 -0400
In-Reply-To: <4E04A609.7010206@fandm.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/24/2011 07:58 AM, Janardhan Iyengar wrote:
> Thanks for your note.  I agree that it does seem like we're simply
> adding to the metaphorical pile.  And my first knee-jerk response would
> be that there's not much else one can do in the modern IPv4 Internet :-)

Thanks, I also appreciate you reviving this thread.  I was surprised at
the hostility here, towards an idea that we both think is necessary and
practical, given the realities of today's Internet.

TCP is at the middle of the hourglass, as you said.  Even UDP isn't
universally allowed (it's not all that uncommon to see UDP blocked,
except for DNS packets to whitelisted DNS servers).  At least one ISP,
"AT&T U-Verse", no longer allows the customer their choice of Internet
router, and the ISP's mandated router will filter all traffic in both
directions, so if the packet isn't recognized by its simple little
stateful firewall, into the bit bucket it goes.  Have fun trying to pass
SCTP or DCCP through that!

> Changes to the API, which is what we're proposing, is not a modification
> to the transport layer protocol per se.  In other words, we are changing
> the service that TCP offers to apps, and not the protocol.

Agreed, and the freedom of Linux to do this is what makes it great.  API
compatibility with other OS's is not an issue, since as you said the app
can always fall back to classical TCP behavior, and since nothing on the
wire changes, it won't break the other OS on the other side of the wire.

> Note:  I'm talking largely about the v4 Internet.  The v6 Internet will
> hopefully have fewer devices that interpose on the transport layer, esp.
> NAPTs;  however, I expect fully that firewalls and PEPs will still use
> transport layer information, requiring them to be able to
> read/understand transport header information.

Like IPv4, most (all?) IPv6 firewalls are stateful, so the firewall has
to be aware of the transport protocol in order to know which packets to
allow back through as replies.  And, for servers behind the firewall,
the firewall must offer a way to punch a hole through it without opening
too wide of a hole, and keep state for incoming connections, so
transport protocol awareness is important there as well.

So, even though we're vastly outnumbered on this mailing list, I remain
interested in your "Minion" paper and its ideas for providing a richer
API to make TCP more versatile to suit a wide variety of needs.

Josh Lehan
