From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 12 Jan 2005 21:21:43 +0100
Message-ID: <16869.34519.31321.977100@robur.slu.se>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
	<200501121025.03899.jeremy.guthrie@berbee.com>
	<16869.31276.256679.96845@robur.slu.se>
	<200501121411.49293.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501121411.49293.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:
 > 
 > Latest numbers after your patch Robert.


 Did the RX interrupts go down?

						--ro


 > Wed Jan 12 14:05:36 CST 2005
 > eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
 >           inet addr:10.253.0.1  Bcast:10.255.255.255  Mask:255.255.255.0
 >           inet6 addr: fe80::202:b3ff:fed5:7e30/64 Scope:Link
 >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
 >           RX packets:21951496 errors:2412189 dropped:2412189 overruns:377090 
 > frame:0
 >           TX packets:5 errors:0 dropped:0 overruns:0 carrier:0
 >           collisions:0 txqueuelen:1000
 >           RX bytes:3455362966 (3295.2 Mb)  TX bytes:398 (398.0 b)
 >           Base address:0x22a0 Memory:eff80000-effa0000
 > 
 > 95b83157 150dc67c 00c734a1 000d2659 00000000 00000000 00000000 00000000 
 > 0073cee4
 > 00044494 00000000 00000075 00000000 00000000 00000000 00000000 00000000 
 > 00097c77
 > entries  in_hit in_slow_tot in_no_route in_brd in_martian_dst in_martian_src  
 > out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss 
 > gc_dst_overflow in_hlist_search out_hlist_search
 > 0000f8cd  41403122 34c30e49 00000000 00000000 0000b0dd 00006a38 00000002  
 > 0027279d 0004147b 00000000 2f528a5f 2f42efcf 0000104f 00000000 81d262df 
 > 00c5d75c
 > 0000f8cd  0000e332 0003238f 00000000 00000000 00004263 00000000 00000000  
 > 0000001e 000000c0 00000002 00004650 00004626 00000000 00000000 0016b879 
 > 0000024c
 > 
 > 
 > 
 > 
 > 
 > Wed Jan 12 14:06:36 CST 2005
 > eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
 >           inet addr:10.253.0.1  Bcast:10.255.255.255  Mask:255.255.255.0
 >           inet6 addr: fe80::202:b3ff:fed5:7e30/64 Scope:Link
 >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
 >           RX packets:28053281 errors:2899869 dropped:2899869 overruns:427243 
 > frame:0
 >           TX packets:5 errors:0 dropped:0 overruns:0 carrier:0
 >           collisions:0 txqueuelen:1000
 >           RX bytes:2607094069 (2486.3 Mb)  TX bytes:398 (398.0 b)
 >           Base address:0x22a0 Memory:eff80000-effa0000
 > 
 > 96154d20 150dc67c 00c78bc2 000d2659 00000000 00000000 00000000 00000000 
 > 0073d31d
 > 00044499 00000000 00000075 00000000 00000000 00000000 00000000 00000000 
 > 00097d2d
 > entries  in_hit in_slow_tot in_no_route in_brd in_martian_dst in_martian_src  
 > out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss 
 > gc_dst_overflow in_hlist_search out_hlist_search
 > 0000fc6a  419ad196 34c586ba 00000000 00000000 0000b0e0 00006a40 00000002  
 > 002729c5 000414cb 00000000 2f5502ff 2f4567f7 0000104f 00000000 83790467 
 > 00c5e33c
 > 0000fc6a  0000e333 00032393 00000000 00000000 00004263 00000000 00000000  
 > 0000001e 000000c0 00000002 00004650 00004626 00000000 00000000 0016b898 
 > 0000024c
 > 
 > 
 > On Wednesday 12 January 2005 01:27 pm, Robert Olsson wrote:
 > > Jeremy M. Guthrie writes:
 > >  > >  > ETH3 Interrupts(calc'd from below):  1479968
 > >  > >
 > >  > >  Very strange...
 > >  > >
 > >  > >  eth3 is bound to CPU0 which in turn has all packet load... If we were
 > >  > >  to believe your CPU0 was saturated (due to the drops). We should see
 > >  > > no (RX) interrupts on eth3. But there is a lot... one irq per every
 > >  > > three packet. Why?
 > >  >
 > >  > I have no idea why it would be doing this.
 > >
 > >  Huh seems you didn't add the patch I sent. Below is diff from my editor to
 > > your e1000_main.c
 > >
 > >        --ro
 > >
 > >
 > > --- e1000_main.c.jmg 2005-01-12 20:14:08.324168072 +0100
 > > +++ e1000_main.c 2005-01-12 20:17:24.777302656 +0100
 > > @@ -2264,14 +2264,13 @@
 > >   netdev->quota -= work_done;
 > >
 > >   /* if no Rx and Tx cleanup work was done, exit the polling mode */
 > > - if(!tx_cleaned || (work_done < work_to_do) ||
 > > -    !netif_running(netdev)) {
 > > +  if( (!tx_cleaned && (work_done == 0)) || !netif_running(netdev)) {
 > >  quit_polling: netif_rx_complete(netdev);
 > >    e1000_irq_enable(adapter);
 > >    return 0;
 > >   }
 > >
 > > - return (work_done >= work_to_do);
 > > + return 1;
 > >  }
 > >
 > >  #endif
 > 
 > -- 
 > 
 > --------------------------------------------------
 > Jeremy M. Guthrie        jeremy.guthrie@berbee.com
 > Senior Network Engineer        Phone: 608-298-1061
 > Berbee                           Fax: 608-288-3007
 > 5520 Research Park Drive         NOC: 608-298-1102
 > Madison, WI 53711
