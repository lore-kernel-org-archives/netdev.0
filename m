From: Sami Farin <safari-kernel@safari.iki.fi>
Subject: Re: Linux 2.6.27.5 / SFQ/HTB scheduling problems
Date: Thu, 13 Nov 2008 13:48:14 +0200
Message-ID: <20081113114814.sslsf752hwbvsh5o@m.safari.iki.fi>
References: <20081111214702.subn3mt7uylkiref@m.safari.iki.fi> <20081113071543.GB4505@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux Networking Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-out.inet.fi ([195.156.147.13]:46394 "EHLO kirsi2.inet.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753109AbYKMLsR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2008 06:48:17 -0500
Received: from safari.iki.fi (80.223.84.180) by kirsi2.inet.fi (8.5.014)
        id 48FC5B890137E886 for netdev@vger.kernel.org; Thu, 13 Nov 2008 13:48:15 +0200
Content-Disposition: inline
In-Reply-To: <20081113071543.GB4505@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 13, 2008 at 07:15:43 +0000, Jarek Poplawski wrote:
> On 11-11-2008 22:47, Sami Farin wrote:
> ...
> > When 2.6.27.5 was sending:
> > 
> > 2008-11-11T21:16:13.488287Z IP (tos 0x0, ttl 255, id 10323, offset 0, flags [none], proto TCP (6), length 7152) 80.223.84.180.40449 > 74.54.226.166.80: ., cksum 0xee52 (incorrect (-> 0x96a4), 4123538094:4123545194(7100) ack 1017886112 win 710 <nop,nop,timestamp 418352 372760162>
> > 2008-11-11T21:16:13.620018Z IP (tos 0x0, ttl 255, id 10328, offset 0, flags [none], proto TCP (6), length 7152) 80.223.84.180.40449 > 74.54.226.166.80: ., cksum 0xee52 (incorrect (-> 0xf1d0), 4123545194:4123552294(7100) ack 1017886112 win 710 <nop,nop,timestamp 418458 372760270>
> > 2008-11-11T21:16:13.751751Z IP (tos 0x0, ttl 255, id 10333, offset 0, flags [none], proto TCP (6), length 7152) 80.223.84.180.40449 > 74.54.226.166.80: ., cksum 0xee52 (incorrect (-> 0xc685), 4123552294:4123559394(7100) ack 1017886112 win 710 <nop,nop,timestamp 418562 372760374>
> > 
> > I noticed it's 7152 bytes a packet!
> > Is this a new trick in 2.6.27 or 2.6.26?
> > But:
> > <3>[ 1583.914947] 0000:00:19.0: eth0: Jumbo Frames not supported.
> > 
> 
> Could you check for TSO (and maybe turn this off) with ethtool?

It was off:

# ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: off
tx-checksumming: off
scatter-gather: off
tcp segmentation offload: off

Sometimes I am also sending over 15000 byte packets according to
tcpdump.  What I'd like to know is:
1) How can I get tcpdump to show the actual packets I am sending,
   without needing to buy another computer for sniffing the packets?
2) What does it really mean when 15000 byte packet is sent?
   Can other packets be queued normally "in between" or am I doomed
   to 250 ms latency, if I happen to e.g. ping one microsecond after
   the first of these packets is being sent?
   Or are many packets of the same stream just coalesced into one
   bigger, if there are no other packets from other streams in
   between, so that is looks neater when tcpdump is used?

P.S. google does not add References header field so scoring does
not work very well :(

-- 
Do what you love because life is too short for anything else.

