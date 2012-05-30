From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Strange latency spikes/TX network stalls on Sun Fire
 X4150(x86) and e1000e
Date: Wed, 30 May 2012 13:04:55 +0200
Message-ID: <1338375895.2760.153.camel@edumazet-glaptop>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6F31@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	davem@davemloft.net
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57588 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416Ab2E3LFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 07:05:00 -0400
Received: by bkcji2 with SMTP id ji2so3976830bkc.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 04:04:59 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6F31@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-30 at 11:52 +0100, David Laight wrote:
> > > +	num_queued = dql->num_queued;
> > 
> > 
> > I suggest :
> > 
> > 	num_queued = ACCESS_ONCE(dql->num_queued);
> > 	
> > Or else compiler is free to do whatever he wants.
> 
> Or make the structure member volatile, then the
> compiler can only read it once.

No. Compiler can read it several times. Really.

> Probably worth while if the value is expected to
> be read like that.

Please don't use lazy volatile.

Unless you really want Linus flames (and ours)

ACCESS_ONCE() is much cleaner.
