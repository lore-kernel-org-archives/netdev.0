From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: [PATCH net] net: fq_codel: Fix off-by-one error
Date: Sat, 30 Mar 2013 16:08:52 +0100
Message-ID: <20130330150852.GA11315@x4>
References: <1364514720-20780-1-git-send-email-subramanian.vijay@gmail.com>
 <1364569280.5113.21.camel@edumazet-glaptop>
 <20130330065345.GA23938@x4>
 <1364654567.5113.85.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ud10.udmedia.de ([194.117.254.50]:50859 "EHLO
	mail.ud10.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756589Ab3C3PIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 11:08:55 -0400
Content-Disposition: inline
In-Reply-To: <1364654567.5113.85.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013.03.30 at 07:42 -0700, Eric Dumazet wrote:
> On Sat, 2013-03-30 at 07:53 +0100, Markus Trippelsdorf wrote:
> > On 2013.03.29 at 08:01 -0700, Eric Dumazet wrote:
> > > 
> > > Just curious, did you play changing the default limit (10240 packets) ?
> > 
> > I did some tests on my home router (running OpenWrt trunk) that is rate-
> > limited with hfsc to the speed of the cable modem.
> > 
> > My tests seem to indicate that lowering the default limit to 1024
> > packets results in much better latency behavior when using bittorrent.
> > 
> > With the default limit (10240 packets) I would get huge ping latencies
> > from 600-1200ms when downloading e.g.:
> > http://download.opensuse.org/distribution/12.3/iso/openSUSE-12.3-DVD-x86_64.iso.torrent
> > with hundreds of peers.
> > 
> > Setting the limit to 1024 did get the latencies back in check (20-30ms
> > with occasional spikes of ~100ms).
> 
> Bittorent uses its own rate limiting technique, defeating
> current cwnd control done in the TCP stack, because of a very known
> problem
> 
> ( http://www.ietf.org/id/draft-ietf-tcpm-newcwv-00.txt )
> 
> So if your goal is reducing latencies for a _given_ class of flows, just
> use prio + 3 fq_codel,  and classify your packets to make sure your
> lovely ping packets are not dropped or behind long packets.

This is exactly the setup that I'm using right now (prio + 4 fq_codel
with bittorent set to low).
And setting the fq_codel limit to 1024 improves latency in this
situation. 
That's all I wanted to communicate. If the result doesn't interest you,
just ignore my mail.

-- 
Markus
