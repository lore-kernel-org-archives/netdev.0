From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Constantly varying download rate with a complex xen networking
 setup, why?
Date: Mon, 15 Jun 2009 17:18:27 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0906151657380.16408@melkinkari.cs.Helsinki.FI>
References: <20090615075313.GA22819@rivendell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Raphael Hertzog <raphael@ouaza.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41948 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506AbZFOOS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 10:18:26 -0400
In-Reply-To: <20090615075313.GA22819@rivendell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Jun 2009, Raphael Hertzog wrote:

> My problem is that when I download a big file from the internet by HTTP in
> the dom0, the download rate is not stable. It goes up progressively and then
> stalls for a few seconds, and restart again going up progressively (and
> all this in loop until the download is complete).

My guess: TCP sawtooth pattern and the associated loss recovery...? What 
you describe here seems to match exactly to what is expected to happen 
because of it (I see this happening quite often actually). What is the 
size of the bottleneck buffer and base RTTs of the relevant flows (HTTP, 
ssh)?

> During the stalls, it looks like all networking is blocked on the 
> machine (noticed on interactive SSH sessions).

They too might be recovering from losses if the bottleneck is shared? 
Please verify "blocking" using tcpdump or so. You may find out e.g. that 
network is not stalled but that out-of-order arrivals prevent 
applications from making progress.

If this matches with your problem, deploying AQM at the bottleneck would 
help.


-- 
 i.
