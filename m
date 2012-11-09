From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: question on netdev_completed_queue()
Date: Fri, 9 Nov 2012 17:09:39 +0000
Message-ID: <1352480979.3159.13.camel@bwh-desktop.uk.solarflarecom.com>
References: <1476426.QTHA7ibVHZ@linux-lqwf.site>
	 <1352407453.2771.18.camel@bwh-desktop.uk.solarflarecom.com>
	 <16131769.FsMAT47cqV@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:55915 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755076Ab2KIRJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 12:09:42 -0500
In-Reply-To: <16131769.FsMAT47cqV@linux-lqwf.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-09 at 17:58 +0100, Oliver Neukum wrote:
> On Thursday 08 November 2012 20:44:13 Ben Hutchings wrote:
> > On Thu, 2012-11-08 at 20:38 +0100, Oliver Neukum wrote:
> > > Hi,
> > > 
> > > is this function to be called whenever a driver is done with transmitting
> > > data, whether the transmission be successful or not?
> > 
> > Yes, BQL tracks number of packets and bytes in each queue and you have
> > to tell it about all insertions and removals from the queue.  (Except
> > that if you flush the queue, you can use netdev_reset_queue() rather
> > than trying to counting the remaining packets and bytes.)
> 
> Thank you. That opens up the next question. How exact does the count
> have to be? Do you care about the exact amount of data or does it just
> have to be internally consistent?

The underlying DQL algorithm doesn't care what it's counting.  However
the administrator can adjust the queue limits through sysfs, and they
will expect the numbers to be byte counts.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
