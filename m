From: Josh Lehan <linux@krellan.com>
Subject: Re: Skipping past TCP lost packet in userspace
Date: Wed, 01 Jun 2011 01:10:11 -0700
Message-ID: <4DE5F3E3.2080609@krellan.com>
References: <4DE44218.4070306@krellan.com> <BANLkTinKORbHHZ7dAqfiFOg5rqB77DcJY8D7AxmP-xwhwmOgGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Josh Lehan <linux@krellan.com>, netdev <netdev@vger.kernel.org>,
	jiyengar@fandm.edu
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server4.hostdango.com ([70.86.37.74]:52486 "EHLO
	server4.hostdango.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161440Ab1FAIKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 04:10:13 -0400
In-Reply-To: <BANLkTinKORbHHZ7dAqfiFOg5rqB77DcJY8D7AxmP-xwhwmOgGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/31/2011 10:23 AM, Yuchung Cheng wrote:
> This paper may have a solution to your problem
> "Minion=97an All-Terrain Packet Packhorse to Jump-Start Stalled Inter=
net
> Transports"
> http://csweb1.fandm.edu/jiyengar/lair/papers/minion-pfldnet2010.pdf

Nice, thanks for pointing me to this.  I appreciate the helpful answer,
instead of just saying "use UDP" or "use SCTP".  That's not the point.

=46or better or for worse, TCP is realistically the only viable protoco=
l
for streaming to the largest possible audience these days, hence my
question about adding this feature to the Linux TCP implementation.

As for the Linux receiver, I was thinking of 2 features:

1) Assuming the application has already read all data that would be
possible without blocking, perform something like an ioctl() to peek at
the data, and peek to see if there is any out-of-order data behind a ga=
p.

2) If the out-of-order data is enough to be useful to the application,
another ioctl() could be done, to ask the kernel to jump over the gap
and deliver the data to the application.  At this point the missing dat=
a
would be considered lost.  The data behind the gap would then be
delivered to the application as part of its normal reading stream.  The
TCP sequence numbers would advance, as usual, just as if the missing
data had been there all along.

This will need some more thought in order to work in real life, such as
needing to be blocked on (select(), poll(), etc.) without having to
busywait the "peek" ioctl.  Also, it would be nice to have an ioctl() t=
o
reclaim the missing data that was skipped over, should that data happen
to successfully arrive late, so that the application could still save i=
t
(or whatever) instead of it having to be discarded.

Josh Lehan
