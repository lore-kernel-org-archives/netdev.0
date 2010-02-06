From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] sky2: Allocate initial skbs in sky2_alloc_buffers
Date: Fri, 5 Feb 2010 22:12:46 -0800
Message-ID: <20100205221246.6fdb3632@s6510>
References: <4B6CC473.4090008@ring3k.org>
	<20100205181045.42908795@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mike McCormack <mikem@ring3k.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47329 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751522Ab0BFGNJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Feb 2010 01:13:09 -0500
In-Reply-To: <20100205181045.42908795@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 5 Feb 2010 18:10:45 -0800
Stephen Hemminger <shemminger@vyatta.com> wrote:

> On Sat, 06 Feb 2010 10:22:59 +0900
> Mike McCormack <mikem@ring3k.org> wrote:
> 
> > Allocating everything in one place means there's a single point
> > of failure in sky2_up, and sky2_rx_start can no longer fail.
> 
> If ring is never allocated, how then it must fail in up.
> Plus if the initial ring allocation is partial it should fail.

Let me put that clearer...
When dev_open is called, the system might be very short of memory
and unable to allocate the number of receive buffers; in that case,
I would prefer that an error was returned to the application.
Yes, this is a corner case; but it is better to fail with a noisy
error than limp along with a dead device.
