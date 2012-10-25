From: Tony Cheneau <tony.cheneau@amnesiak.org>
Subject: Re: [PATCH net-next 00/15] 6lowpan: Some more bug fixes
Date: Thu, 25 Oct 2012 16:49:28 +0200
Message-ID: <383f66ae460548de6f930b0f1c244e5a@amnesiak.org>
References: <1350965397-12384-1-git-send-email-tony.cheneau@amnesiak.org>
 <CAJmB2rDcdo7r-0xoNnrbXRB4KKWoKJmpu9OTk5HHuE1V5Py2qA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-zigbee-devel@lists.sourceforge.net>,
	Alan Ott <alan@signal11.us>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.amnesiak.org ([95.130.11.136]:40456 "EHLO amnesiak.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756149Ab2JYOty (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 10:49:54 -0400
In-Reply-To: <CAJmB2rDcdo7r-0xoNnrbXRB4KKWoKJmpu9OTk5HHuE1V5Py2qA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Alexander,

Thank you for your comments. See my answer inline.

Le 25.10.2012 06:52, Alexander Smirnov a =C3=A9crit=C2=A0:
> Hi,
>
[...]
> 1. The series is quite huge what makes it difficult for the review.=20
> It
> would be better to split it into one-two and submit separately (not
> simultaneously).
OK. Will do.

> 2. Could you also please provide some notes about how have you tested
> these changes (logs, plain text)? Do I need to check your changes
> locally on my desk? If so I need some instructions.
I'm not sure what you are asking here. There was some more debugging=20
printk, that I removed because they were too verbose. Mostly, I test my=
=20
patch with few userspace program, like ping6, iperf (both for TCP and=20
UDP) and ssh. I also wrote a TCP and a UDP echo server, so as to test=20
fragmentation in more details. For most functional patches, I usually=20
confirm through wireshark that the packets indeed look the way they=20
should (this, I've done it for patch 11 for example). But I don't have=20
any automated scripts to check for regression. I can provide you the=20
script I use to configure nodes if needed (but it pretty straighward an=
d=20
should look like your own scripts).
I'm not sure that really answers your question.

> 3. Please DO NOT submit patches like: this patch fixes blablabla=20
> which
> isn't in the kernel yet (like patch 13,15). I have no clue what you
> have locally on your laptop and what you will send in some time. I'd
> like to see here the working code, not a references to TBD.
I'm OK with removing patch 13 (I'll introduce it alongside the serial=20
driver later on). I'm not so OK with removing patch 15, or at least, it=
=20
would require some more testing in other parts of the code. Basically,=20
the TBD are placeholder for when the Association Request/Response will=20
be reimplemented. I introduced it because otherwise, .assoc_req and=20
=2Eassoc_resp entries of mac802154_mlme_wpan would go uninitialized and=
=20
would cause kernel crash when called. I could have modified the calling=
=20
code to deal with that, but I thought these primitives were meant to be=
=20
re-implemented soon anyway.

> 4. The reference to linux-zigbee project isn't an occasion for me to
> apply this code to this tree. I have no goal to merge all this fun to
> mainline due to several things in linux-zigbee kernel work NOT
> according to the standard (mostly it's a timing problems) and global
> refactoring needed.
I don't understand what you are talking about here. I would guess that=20
you are talking about patch 15. If so, my answer is the following, whil=
e=20
I understand your effort to refactor linux-zigbee code and fix things=20
along the way, some code went through net-next that cause crashes. My=20
pragmatic approach is to try to fix it before more people use it, even=20
through it might not always be the most elegant way to do it.

Regards,
Tony
