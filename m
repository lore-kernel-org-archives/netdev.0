From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: Will RFC1146 (tcp alternative checksum options) be implemented
	in Linux tcp stack ?
Date: Tue, 16 Oct 2007 13:28:51 +0300
Message-ID: <20071016102851.GZ6372@mea-ext.zmailer.org>
References: <887901.30138.qm@web55205.mail.re4.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Yanping Du <ypdu2001@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from z2.cat.iki.fi ([212.16.98.133]:51052 "EHLO z2.cat.iki.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760671AbXJPK2z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 06:28:55 -0400
Received: (mea@mea-ext) by mail.zmailer.org id S3540066AbXJPK2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 13:28:51 +0300
Content-Disposition: inline
In-Reply-To: <887901.30138.qm@web55205.mail.re4.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 15, 2007 at 06:15:11PM -0700, Yanping Du wrote:
> Hi,
> 
>   We found the standard 16-bit tcp checksum is not
> strong enough in some cases. Is there any roadmap on
> implementing RFC1146 (tcp alternative checksum
> options) in Linux tcp stack ? If yes, how soon will
> that be in ?

If you want to pay to somebody to implement it, possibly soon.
Otherwise it is up to whims of capable kernel coders, who
usually have their hands quite full.

The tcp alternate checksum option does have severe performance
hinderance issue.  It may be implemented by intermingling it
into standard tcp_checksum_and_copy routine, but in cases
where the hardware can do tcp checksum offloading, it definitely
does not improve the performance.

Your alternate approach could be to use a IPSEC VPN tunnel,
which will detect an attempt to alter data ( = transmission
error ) even when the original TCP does not detect anything.

Yet third way could be to do it in application: ssh datastream
as one example - or tunnel via SSH port forward.

Need for alternate checksums does appear to indicate that you
are using bad quality transmission system -- those are not
usually very high speed things, and then hacks like IPSEC or
SSH tunnels are excellent choices.

Nevertheless, adding checksum complexity/size on each packet
does not guarantee error detection, it merely lowers the
probability of error detection failure.  There _will_ happen
an error which wasn't detected, but will it be once a minute
or once a year, or once per billion years..

Bad quality ( = error introducing ) transmission system will
also make speedy data transmission that much more difficult,
thus my presumption that it isn't very fast link...

Anyway, we have seen data corruption on disk, over the network
etc.  Having application level MD5 checksumming of the datastream
every N kilobytes has its own attractions.  Including embedding
those checksums in the stored datastreams.


> Please kindly copy reply to my email address as I've
> not subscribed the netdev@ mailing list at present.
> 
>   http://www.faqs.org/rfcs/rfc1146.html
> 
> Thanks!
> -Yanping

/Matti Aarnio
