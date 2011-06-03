From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Skipping past TCP lost packet in userspace
Date: Fri, 3 Jun 2011 14:51:40 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1106031428280.17529@wel-95.cs.helsinki.fi>
References: <4DE44218.4070306@krellan.com> <BANLkTinKORbHHZ7dAqfiFOg5rqB77DcJY8D7AxmP-xwhwmOgGg@mail.gmail.com> <4DE5F3E3.2080609@krellan.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-551681870-1307100584=:17529"
Cc: netdev <netdev@vger.kernel.org>
To: Josh Lehan <linux@krellan.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40537 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619Ab1FCLvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 07:51:41 -0400
In-Reply-To: <4DE5F3E3.2080609@krellan.com>
Content-ID: <alpine.DEB.2.00.1106031436020.17529@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-551681870-1307100584=:17529
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1106031431291.17529@wel-95.cs.helsinki.fi>

On Wed, 1 Jun 2011, Josh Lehan wrote:

> On 05/31/2011 10:23 AM, Yuchung Cheng wrote:
> > This paper may have a solution to your problem
> > "Minion—an All-Terrain Packet Packhorse to Jump-Start Stalled Internet
> > Transports"
> > http://csweb1.fandm.edu/jiyengar/lair/papers/minion-pfldnet2010.pdf
> 
> Nice, thanks for pointing me to this.  I appreciate the helpful answer,
> instead of just saying "use UDP" or "use SCTP".  That's not the point.
> 
> For better or for worse, TCP is realistically the only viable protocol
> for streaming to the largest possible audience these days, hence my
> question about adding this feature to the Linux TCP implementation.
> 
> As for the Linux receiver, I was thinking of 2 features:
> 
> 1) Assuming the application has already read all data that would be
> possible without blocking, perform something like an ioctl() to peek at
> the data, and peek to see if there is any out-of-order data behind a gap.
> 
> 2) If the out-of-order data is enough to be useful to the application,
> another ioctl() could be done, to ask the kernel to jump over the gap
> and deliver the data to the application.  At this point the missing data
> would be considered lost.  The data behind the gap would then be
> delivered to the application as part of its normal reading stream.  The
> TCP sequence numbers would advance, as usual, just as if the missing
> data had been there all along.

And you'd send a cumulative ACK without the actual data segment...? 
...That's gonna break many middleboxes which would want to see that 
data segment too ...And there goes your "viability" (though with luck it 
will _sometimes_ work as rexmit of the data segment is already in flight). 

...The fact is that such change into TCP wire behavior is no longer TCP 
enough to work reliably.

In addition, such a non-legimite cumulative ACK probably violates number 
of TCP RFCs or at least assumptions made in them... e.g., for starters, 
please explain which timestamp you would be putting there into that 
particular cumulative ACK?


-- 
 i.
--8323329-551681870-1307100584=:17529--
