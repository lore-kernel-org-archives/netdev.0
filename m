From: John Bermudez <jbermudez@vnocservice.com>
Subject: Re: e1000 - rx misses
Date: Thu, 3 Mar 2011 15:00:42 -0500
Message-ID: <2DF55ECAAA7FFF478FB4ED007EF478E7656B1010BB@NETS.hillside.glowpoint.com>
References: <2DF55ECAAA7FFF478FB4ED007EF478E7656B070D76@NETS.hillside.glowpoint.com>
	<alpine.WNT.2.00.1102281058040.5424@JBRANDEB-DESK2.amr.corp.intel.com>
	<2DF55ECAAA7FFF478FB4ED007EF478E7656B100F27@NETS.hillside.glowpoint.com>
	<alpine.WNT.2.00.1103011658050.5424@JBRANDEB-DESK2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2290582381218899351=="
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Ronciak,
	John" <john.ronciak@intel.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.WNT.2.00.1103011658050.5424@JBRANDEB-DESK2.amr.corp.intel.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============2290582381218899351==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_2DF55ECAAA7FFF478FB4ED007EF478E7656B1010BBNETShillsideg_"

--_000_2DF55ECAAA7FFF478FB4ED007EF478E7656B1010BBNETShillsideg_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Jesse,

Thanks for your time.
your answers have pointed me in the right direction
which has let me do hours of positive research


so this leads me to one final question ( I hope ;) )

lspci -v shows that the latency for the Ethernet device(s)
is 0

Is this the default value populated by the e1000 driver??
or who's responsibility is it to populate this value

i.e.

04:00.1 Ethernet controller: Intel Corporation: Unknown device 105e (rev 06=
)
        Subsystem: Intel Corporation: Unknown device 346e
        Flags: bus master, fast devsel, latency 0, IRQ 18
        Memory at b8920000 (32-bit, non-prefetchable) [size=3D128K]
        Memory at b8900000 (32-bit, non-prefetchable) [size=3D128K]
        I/O ports at 3000 [size=3D32]
        Expansion ROM at fffe0000 [disabled] [size=3D128K]
        Capabilities: [c8] Power Management version 2
        Capabilities: [d0] Message Signalled Interrupts: 64bit+ Queue=3D0/0=
 Enable-
        Capabilities: [e0] #10 [0001]



Thank you and have a nice day,

Mr. John Bermudez
NOC Level 3 Engineer


-----Original Message-----
From: Brandeburg, Jesse [mailto:jesse.brandeburg@intel.com]
Sent: Tuesday, March 01, 2011 5:02 PM
To: John Bermudez
Cc: Ronciak, John; Kirsher, Jeffrey T; netdev@vger.kernel.org; e1000-devel@=
lists.sourceforge.net
Subject: RE: e1000 - rx misses

<removed non-relevant users>

On Tue, 1 Mar 2011, John Bermudez wrote:

> Thanks for your time
> Can you tell me the command to lengthen the input fifo rx queue?
> is this possible

You can try increasing the number of rx buffers via the command
# ethtool -G ethX rx 4096

and if you were really gung ho, you could increase the amount of fifo
allocated to the rx side of the fifo by modifying the source.  That said,
I don't think that will buy you anything because it seems from the small
amount of data provided that you are having exceptionally long periods of
time where the data is coming faster than your machine can process (for
whatever reason) and increasing the fifo only will give you a marginal
(4kB or so) increasing in buffering.



>
> -----Original Message-----
> From: Brandeburg, Jesse [mailto:jesse.brandeburg@intel.com]
> Sent: Monday, February 28, 2011 11:05 AM
> To: John Bermudez
> Cc: cramerj; Ronciak, John; Kirsher, Jeffrey T; Kok, Auke-jan H; netdev@v=
ger.kernel.org; e1000-devel@lists.sourceforge.net
> Subject: Re: e1000 - rx misses
>
> added e1000-devel, responses inline...
>
> On Wed, 23 Feb 2011, John Bermudez wrote:
>
> > Hello All,
> > I got your contact info in a forum.
> > maybe you could give me a quick pointer.
> >
> > I have a device that is experiencing RX misses. I tried 1000/full and 1=
00/full
> > it occurs at both speeds. I seem to get a burst of loss so I am assumin=
g I am overrunning the FIFO RX queue.
>
> overrunning at 100Mb/s seems pretty unlikely to be our hardware's fault,
> as your buffer (in time) is increasing by 10x.
>
> >
> > Any known workarounds?
> > Configuration modifications?
> >
> > your time is much appreciated
> >
> >
> >
> > /lib/modules/2.4.31-uc0/kernel/drivers/net/e1000
> > # ls
> > e1000.o
>
> ow, 2.4.31 kernel is pretty much so old as to not be supportable.
>
> > # ethtool -S eth1
> > NIC statistics:
> >      rx_packets: 217454512
> >      tx_packets: 266698397
> >      rx_bytes: 172995819593
> >      tx_bytes: 246744709750
> >      rx_broadcast: 0
> >      tx_broadcast: 528
> <snip>
> >      rx_no_buffer_count: 925
>
> This count above indicates that your cpu is not returning buffers to
> hardware fast enough.  Do you have NAPI enabled?
>
> >      rx_missed_errors: 48206
>
> This error means that for the length of time the fifo was buffering the
> adapter was not able to get any data buffers from the OS, filled the FIFO
> and had to drop this many packets.
>
> >      tx_aborted_errors: 0
> >      tx_carrier_errors: 0
> >      tx_fifo_errors: 0
> >      tx_heartbeat_errors: 0
> >      tx_window_errors: 0
> >      tx_abort_late_coll: 0
> >      tx_deferred_ok: 0
> >      tx_single_coll_ok: 0
> >      tx_multi_coll_ok: 0
> >      tx_timeout_count: 0
> >      tx_restart_queue: 0
> >      rx_long_length_errors: 0
> >      rx_short_length_errors: 0
> >      rx_align_errors: 0
> >      tx_tcp_seg_good: 0
> >      tx_tcp_seg_failed: 0
> >      rx_flow_control_xon: 0
> >      rx_flow_control_xoff: 0
> >      tx_flow_control_xon: 0
> >      tx_flow_control_xoff: 0
>
> flow control is either not happenning or is disabled, if it is disabled
> you could try enabling it on both ends to get a little more buffering in
> your switch.
>
> >      rx_long_byte_count: 172995819593
> >      rx_csum_offload_good: 217406235
> >      rx_csum_offload_errors: 17
> >      rx_header_split: 0
> >      alloc_rx_buff_failed: 0
> >      tx_smbus: 0
> >      rx_smbus: 5262
>
> hm, you have IPMI traffic, could these be related to your stalls?
>
> >      dropped_smbus: 0
> > #
> >
> >
> > Thank you and have a nice day,
> >
> > Mr. John Bermudez
> > NOC Level 3 Engineer
> >
> >
>
> You didn't include lots of data we need, like hardware type, adapter/chip=
,
> ethtool -i output, cat /proc/interrupts, system info, .config, etc.
>
> I suggest that something is running either in interrupt context on your
> system for a very long time (keeping us from running our interrupt
> handler) or that your cpu is underpowered and unable to keep up with
> whatever tasks it is running besides the network driver.
>
> If you wish to continue troubleshooting please file a bug at e1000.sf.net
> and attach the requested info there.
>
> Jesse
>


--_000_2DF55ECAAA7FFF478FB4ED007EF478E7656B1010BBNETShillsideg_--


--===============2290582381218899351==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Free Software Download: Index, Search & Analyze Logs and other IT data in 
Real-Time with Splunk. Collect, index and harness all the fast moving IT data 
generated by your applications, servers and devices whether physical, virtual
or in the cloud. Deliver compliance at lower cost and gain new business 
insights. http://p.sf.net/sfu/splunk-dev2dev 
--===============2290582381218899351==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============2290582381218899351==--
