From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] pktgen handle netdev device getting full.
Date: Thu, 16 Sep 2004 16:22:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414A2035.2040304@candelatech.com>
References: <20040916144332.37f19fcb@dell_ss3.pdx.osdl.net>	<414A1AD2.1090109@candelatech.com> <20040916155913.577b878b.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, Robert.Olsson@data.slu.se, davem@redhat.com,
        netdev@oss.sgi.com, hadi@znyx.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040916155913.577b878b.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Thu, 16 Sep 2004 15:59:30 -0700
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>Stephen Hemminger wrote:
>>
>>>I was trying out pktgen on a NIC with an undersized ring, so 
>>>hard_start_xmit would always return non-zero when full.  This caused a slew
>>>of console messages.  Better to just have pktgen retry in this case.
>>
>>My understanding is that if the queue is not stopped, then you
>>should not get the hard xmit errors.  So, in a proper driver,
>>you should not see these printks.
> 
> 
> That is absolutely correct, that is why Stephen's patch is
> not correct (aside from the do_div() part which I'll happily
> apply if submitted by itself).

Well, in his defense, the e1000 and probably other drivers
will cause this printk to happen (or, at least earlier versions
of the e1000 in the 2.4.25 kernel will).

>>By the way, is there any interest in adding my patch that also allows
>>pktgen to receive packets (and count the statistics, etc)?  I know
>>DaveM objected to the hook in the skb-receive logic some time back,
>>but maybe he has a different opinion now?
> 
> 
> I still object to this, it will be abused.

Even if the hook is exported GPL?  (The bridging hook is almost
identical in abusability, and it is not even exported GPL, just plain
exported....)

Just for grins, here is the /proc output from one of my tests.  This
is a pair of GigE nics running back to back on the same machine.  Since
it is the same clock, we can get very exact latency numbers, as well as
packet drops, etc....


VERSION-1
Params: count 0  min_pkt_size: 60  max_pkt_size: 60  cur_pkt_size 60
      frags: 0  ipg: 11478  multiskb: 0  ifname: eth2
      dst_min: 172.2.2.3  dst_max: 172.2.2.3
      src_min: 172.2.2.2  src_max: 172.2.2.2
      src_mac: 00:07:E9:1F:97:C9  dst_mac: 00:07:E9:1F:97:C8
      udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
      src_mac_count: 0  dst_mac_count: 0  peer_multiskb: 0
      Flags:
Current:
      pkts-sofar: 3488264  errors: 0
      started: 1095376671654330us  elapsed: 43664674us
      idle: 42349478538ns  next_tx: 211092296137443(24804)ns
      seq_num: 3488265  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
      cur_saddr: 0x20202ac  cur_daddr: 0x30202ac  cur_udp_dst: 9  cur_udp_src: 9
      pkts_rcvd: 3488254  bytes_rcvd: 174412700  last_seq_rcvd: 3488254  ooo_rcvd: 0
      dup_rcvd: 0  seq_gap_rcvd(dropped): 0  non_pg_rcvd: 0
      avg_latency: 148us  min_lat: 6us  max_lat: 2259us  pkts_in_sample: 3488254
       Buckets(us) [ 0  0  0  14416  55106  138901  266024  523649  1040910  1382427  66662  139  20  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  ]




-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
