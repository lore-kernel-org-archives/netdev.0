From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bad TCP timestamps on non-PC platforms
Date: Sun, 9 Jan 2011 19:57:11 -0800
Message-ID: <20110109195711.1d622b2e@nehalam>
References: <798351.95533.qm@web37603.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Alex Dubov <oakad@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57524 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751501Ab1AJD5N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jan 2011 22:57:13 -0500
In-Reply-To: <798351.95533.qm@web37603.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 9 Jan 2011 19:41:13 -0800 (PST)
Alex Dubov <oakad@yahoo.com> wrote:

> > > 
> > > You dont give new informations ;)
> > > 
> 
> Some additional information (my wireshark was not validating checksums, so
> I missed the real culprit).
> 
> It so appears, that when timestamps are enabled on my dev board, TCP
> checksum in SYN packet turns out to be incorrect. That's why those packets
> are dropped by the remote side. When TCP timestamps are disabled, checksums
> are correct.
> 
> Any ideas where this particular problem may originate?

Is there a bug in checksum offload in the driver?
Does the hardware correctly handle checksum of packets that are
unaligned or whose length is an odd number of bytes?

If the hardware can't do checksum correctly, the driver should either
disable checksum offload or in worst case copy the packet to a new
buffer that is in a known safe place.
