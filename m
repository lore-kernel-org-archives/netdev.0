From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH][RFC] network splice receive
Date: Wed, 6 Jun 2007 09:14:08 +0200
Message-ID: <20070606071407.GD31415@kernel.dk>
References: <20070605080542.GA9909@kernel.dk> <20070605114545.GC9909@kernel.dk> <20070605122031.GE9909@kernel.dk> <1181046894.5896.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:14811 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750886AbXFFHQH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2007 03:16:07 -0400
Content-Disposition: inline
In-Reply-To: <1181046894.5896.5.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 05 2007, jamal wrote:
> On Tue, 2007-05-06 at 14:20 +0200, Jens Axboe wrote:
> 
> > > 
> > > 0000 1800 4ff3 937f e000 6381 7275 0008
> > > 
> > > Perhaps that hex pattern rings a bell with someone intimate with the
> > > networking. The remaining wrong bytes don't seem to have anything in
> > > common.
> > 
> > Ok, the source mac address is 00:18:F3:4F:7F:93 and the destination is
> > 00:E0:81:63:75:72 which are the middle 12 bytes of the 16.
> > 
> 
> It appears you may have endianness issues and perhaps a 16 bit
> mis-offset. the 0008 at the end looks like a swapped 0x800 which
> is the ethernet type for IPV4.

Yeah, it looks like the first part of the ethernet frame. I'm using an
e1000 on the receive side and a sky2 on the sender.

> > Hope that helps someone clue me in as to which network part is reusing
> > the data. Do I need to 'pin' the sk_buff until the pipe data has been
> > consumed?
> 
> I would worry about the driver level first - likely thats where your
> corruption is.

I'd just be a heck-of-a-lot more inclined to suspect my code! Hence I
thought that data reuse for perhaps another packet would be the likely
explanation, especially since it looked like valid network driver data
ending up where it should not.

-- 
Jens Axboe

