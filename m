From: N N Ashok <nalkunda@egr.msu.edu>
Subject: Difference between (struct tc_stats) and (struct net_device_stats)
Date: Fri, 18 Jul 2003 23:55:30 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307182355.30867.nalkunda@egr.msu.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi All,
   The tc_stats and net_device_stats are defined as below:
struct tc_stats
{
	__u64	bytes;			/* NUmber of enqueues bytes */
	__u32	packets;		/* Number of enqueued packets	*/
	__u32	drops;			/* Packets dropped because of lack of resources */
	__u32	overlimits;		/* Number of throttle events when this
<snip>
};
struct net_device_stats
{
	unsigned long	rx_packets;		/* total packets received	*/
	unsigned long	tx_packets;		/* total packets transmitted	*/
	unsigned long	rx_bytes;		/* total bytes received 	*/
	unsigned long	tx_bytes;		/* total bytes transmitted	*/
	unsigned long	rx_errors;		/* bad packets received		*/
	unsigned long	tx_errors;		/* packet transmit problems	*/
	unsigned long	rx_dropped;		/* no space in linux buffers	*/
	unsigned long	tx_dropped;		/* no space available in linux	*/
	unsigned long	multicast;		/* multicast packets received	*/
	unsigned long	collisions;
<snip>
};

      I add an estimator to one of my interfaces and if I observe, the 
bytes,packets in tc_stats for the estimator are not the same as rx_packets, 
rx_bytes of net_device_stats obtainted by get_stats(dev) of the same 
interface at almost the same time. Is there a difference in the meaning/range 
of the two structure fields? In net_device_stats, we have counts for drops, 
errors but no such fields for tc_stats. Are these counts also included in the 
bytes, packets fields of tc_stats?

Thanks,
Ashok
