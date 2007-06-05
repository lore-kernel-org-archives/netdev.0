From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][RFC] network splice receive
Date: Tue, 05 Jun 2007 08:34:54 -0400
Message-ID: <1181046894.5896.5.camel@localhost>
References: <20070605080542.GA9909@kernel.dk>
	 <20070605114545.GC9909@kernel.dk>  <20070605122031.GE9909@kernel.dk>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:59635 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755250AbXFEMe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 08:34:57 -0400
Received: by py-out-1112.google.com with SMTP id a29so2839673pyi
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2007 05:34:57 -0700 (PDT)
In-Reply-To: <20070605122031.GE9909@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-05-06 at 14:20 +0200, Jens Axboe wrote:

> > 
> > 0000 1800 4ff3 937f e000 6381 7275 0008
> > 
> > Perhaps that hex pattern rings a bell with someone intimate with the
> > networking. The remaining wrong bytes don't seem to have anything in
> > common.
> 
> Ok, the source mac address is 00:18:F3:4F:7F:93 and the destination is
> 00:E0:81:63:75:72 which are the middle 12 bytes of the 16.
> 

It appears you may have endianness issues and perhaps a 16 bit
mis-offset. the 0008 at the end looks like a swapped 0x800 which
is the ethernet type for IPV4.

> Hope that helps someone clue me in as to which network part is reusing
> the data. Do I need to 'pin' the sk_buff until the pipe data has been
> consumed?

I would worry about the driver level first - likely thats where your
corruption is.

cheers,
jamal

