From: Timo Teras <timo.teras@iki.fi>
Subject: Re: linux-3.0.18+r8169+ipv4/tcp forwarding = tso/gso weirdness and
 performance degration
Date: Wed, 14 Mar 2012 21:51:42 +0200
Message-ID: <20120314215142.655ae607@vostro>
References: <20120314190156.622c8cd5@vostro>
	<1331745314.6022.27.camel@edumazet-glaptop>
	<20120314192945.65867e9f@vostro>
	<1331753354.2564.7.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61256 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030724Ab2CNTwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 15:52:19 -0400
Received: by bkcik5 with SMTP id ik5so1585459bkc.19
        for <netdev@vger.kernel.org>; Wed, 14 Mar 2012 12:52:16 -0700 (PDT)
In-Reply-To: <1331753354.2564.7.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Mar 2012 19:29:14 +0000 Ben Hutchings
<bhutchings@solarflare.com> wrote:

> On Wed, 2012-03-14 at 19:29 +0200, Timo Teras wrote:
> [...]
> > gro off. I am even trying now with:
> > 
> > Offload parameters for eth2:
> > rx-checksumming: off
> > tx-checksumming: off
> > scatter-gather: off
> > tcp segmentation offload: off
> > udp fragmentation offload: off
> > generic segmentation offload: off
> [...]
> 
> GRO isn't even reported there!  Apparently you need a newer version of
> ethtool.

Very good point. I thought gso also enabled gro, but seems that my
ethtool was old.

And GRO was enabled along with some other stuff. Turning GRO off made
my tcp performance immediately a lot better; jumped from 2MB/s to 8MB/s
or so (not ideal yet, though; but the remainder of the difference could
be related to other issue).

So something is definitely broke in 3.0.x with GRO enabled, but GSO off.
