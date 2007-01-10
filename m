From: "Simon Barber" <simon@devicescape.com>
Subject: RE: d80211: How does TX flow control work?
Date: Wed, 10 Jan 2007 10:29:34 -0800
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F01AF6471@dhost002-46.dex002.intermedia.net>
References: <20070110192012.341b2612@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Ivo Van Doorn" <ivdoorn@gmail.com>,
	<rt2400-devel@lists.sourceforge.net>,
	"Jouni Malinen" <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:31788 "EHLO
	dhost002-46.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964984AbXAJS26 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 13:28:58 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20070110192012.341b2612@griffin.suse.cz>
To: "Jiri Benc" <jbenc@suse.cz>, "Jan Kiszka" <jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Scratches head -- this is from memory when I was thinking about this
problem a long time ago... I think we can return an error in the qdisc
destructor function - making sure legitimate interface removal is not
the cause of the qdisc deletion first of course.

Simon 

-----Original Message-----
From: Jiri Benc [mailto:jbenc@suse.cz] 
Sent: Wednesday, January 10, 2007 6:20 PM
To: Jan Kiszka
Cc: netdev@vger.kernel.org; Ivo Van Doorn;
rt2400-devel@lists.sourceforge.net; Jouni Malinen; Simon Barber
Subject: Re: d80211: How does TX flow control work?

On Mon, 08 Jan 2007 21:18:48 +0100, Jan Kiszka wrote:
> The actual problem was meanwhile identified: shorewall happened to 
> overwrite the queueing discipline of wmaster0 with pfifo_fast. I found

> the magic knob to tell shorewall to no longer do this (at least until 
> I want to manage traffic control that way...), but I still wonder if 
> it is an acceptable situation. Currently, the user can intentionally 
> or accidentally screw up the stack this way.

Hm, we probably need a way to tell the kernel not to remove 802.11
qdisc. Jouni, Simon, is that possible or do we need to patch NET_SCHED
code?

Thanks,

 Jiri

--
Jiri Benc
SUSE Labs
