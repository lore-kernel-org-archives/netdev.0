From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: question on netdev_completed_queue()
Date: Thu, 8 Nov 2012 20:44:13 +0000
Message-ID: <1352407453.2771.18.camel@bwh-desktop.uk.solarflarecom.com>
References: <1476426.QTHA7ibVHZ@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:9303 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756504Ab2KHUoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 15:44:16 -0500
In-Reply-To: <1476426.QTHA7ibVHZ@linux-lqwf.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-08 at 20:38 +0100, Oliver Neukum wrote:
> Hi,
> 
> is this function to be called whenever a driver is done with transmitting
> data, whether the transmission be successful or not?

Yes, BQL tracks number of packets and bytes in each queue and you have
to tell it about all insertions and removals from the queue.  (Except
that if you flush the queue, you can use netdev_reset_queue() rather
than trying to counting the remaining packets and bytes.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
