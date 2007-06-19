From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Tue, 19 Jun 2007 18:09:44 +0400
Message-ID: <20070619140944.GA26241@2ka.mipt.ru>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com> <1181216629.4064.22.camel@localhost> <20070619132148.GA32078@2ka.mipt.ru> <20070619133333.GA19667@2ka.mipt.ru> <20070619140038.GA13629@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:41673 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755709AbXFSObo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2007 10:31:44 -0400
Content-Disposition: inline
In-Reply-To: <20070619140038.GA13629@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 19, 2007 at 06:00:39PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> On Tue, Jun 19, 2007 at 05:33:33PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > On Tue, Jun 19, 2007 at 05:21:48PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > > Simple test included test -> desktop and vice versa traffic with 128 and
> > > 4096 block size in netperf-2.4.3 setup.
> > 
> > I.e. it is not pktgen, but usual userspace application, which should not
> > use new batch methods.
> > 
> > I will try to find pktget scripts posted in this thread.
> 
> pktgen reults are quite poor:
> batch (changed from default script: count reduced, clone increased to 10k)
> 241319pps 115Mb/sec
> 
> mainline (the same script, on start it wrote about unsupported batch_low
> parameter:
> 497520pps 238Mb/sec


And here is with batch_low=400:

182607pps 87Mb/sec

Here is output for batch_low=0 batch tree (batch_low=400 is similar,
with min_batch parameter set to 400):

Params: count 1000000  min_pkt_size: 60  max_pkt_size: 60 min_batch 0
     frags: 0  delay: 0  clone_skb: 10000  ifname: eth1
     flows: 0 flowlen: 0
     dst_min: 192.168.4.81  dst_max: 
     src_min:   src_max: 
     src_mac: 00:0E:0C:B8:63:0A  dst_mac: 00:17:31:9A:E5:BE
     udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
     src_mac_count: 0  dst_mac_count: 0
     Flags: 
Current:
     pkts-sofar: 1000000  errors: 0
     started: 1182274184549351us  stopped: 1182274188693235us idle: 20us alloc 4007752us txt 127073us
     seq_num: 1000001  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
     cur_saddr: 0x3000a8c0  cur_daddr: 0x5104a8c0
     cur_udp_dst: 9  cur_udp_src: 9
     flows: 0
Result: OK: T4143884(U4143864+I20+A4007752+T127073) usec, P1000000 TE8511TS1(B60,-1frags)
  241319pps 115Mb/sec (115833120bps) errors: 0



-- 
	Evgeniy Polyakov
