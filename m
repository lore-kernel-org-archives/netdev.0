From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: why all packets have same queue no when rps enabled?
Date: Tue, 22 Feb 2011 12:45:56 +0000
Message-ID: <1298378756.2211.478.camel@localhost>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F24D3DE6D0C@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jon Zhou <Jon.Zhou@jdsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:2097 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351Ab1BVMqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 07:46:00 -0500
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F24D3DE6D0C@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-02-21 at 20:07 -0800, Jon Zhou wrote:
> Hi
> 
> I expect each incoming packet will have a different queue no. when I
> enabled RPS on kernel 2.6.36.4
[...]
> Looks almost all packets fall at same queue?
> Will RPS allocate queue no for each packet? and what hash algorithm
> rps used? (is it Toeplitz hash algorithm?)

The queue number identifies a hardware queue.  RPS therefore does not
update this number when queueing packets for processing on other CPUs.

If the hardware/driver provides a receive hash (probably Toeplitz) then
this is used for RPS.  Otherwise a much cheaper hash is used.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

