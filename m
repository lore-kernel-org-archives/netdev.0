From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 0/2] Sysfs net class .
Date: Thu, 15 May 2003 16:27:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030515162712.61cd153e.shemminger@osdl.org>
References: <20030513150303.A2406@DYN318281.beaverton.ibm.com>
	<200305131657.03508.dsteklof@us.ibm.com>
	<20030514142023.0e411f34.shemminger@osdl.org>
	<200305141443.57169.dsteklof@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, greg@kroah.com, mochel@osdl.org, jkenisto@us.ibm.com,
   lkessler@us.ibm.com, Daniel Stekloff
 <dsteklof@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Patrick Mochel <mochel@osdl.org>
In-Reply-To: <200305141443.57169.dsteklof@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Starting with work by Pat and Daniel Stekoff , I created a sysfs network interface.

There are two parts, one is the core network device piece to create
sysfs entries during init and register. The other is changing the device
drivers so that during registration the appropriate symlinks back to the
pci physical devices gets made.

All this is under a config option in case embedded or other systems
don't need it.  The files are in sysfs standard format with one value per
file.  Most are read-only, although some like flags, mtu, can be set.

The sysfs tree layout is:

class/net
|-- eth0
|   |-- addr_len
|   |-- address
|   |-- broadcast
|   |-- device -> ../../../devices/pci0/00:1e.0/04:04.0
|   |-- driver -> ../../../bus/pci/drivers/e100
|   |-- features
|   |-- flags
|   |-- if_port
|   |-- ifindex
|   |-- mtu
|   |-- statistics
|   |   |-- collisions
|   |   |-- multicast
|   |   |-- rx_bytes
|   |   |-- rx_compressed
|   |   |-- rx_crc_errors
|   |   |-- rx_dropped
|   |   |-- rx_errors
|   |   |-- rx_fifo_errors
|   |   |-- rx_frame_errors
|   |   |-- rx_length_errors
|   |   |-- rx_missed_errors
|   |   |-- rx_over_errors
|   |   |-- rx_packets
|   |   |-- tx_aborted_errors
|   |   |-- tx_bytes
|   |   |-- tx_carrier_errors
|   |   |-- tx_compressed
|   |   |-- tx_dropped
|   |   |-- tx_errors
|   |   |-- tx_fifo_errors
|   |   |-- tx_heartbeat_errors
|   |   |-- tx_packets
|   |   `-- tx_window_errors
|   |-- tx_queue_len
|   `-- type
`-- lo
    |-- addr_len
    |-- address
    |-- broadcast
    |-- features
    |-- flags
    |-- if_port
    |-- ifindex
    |-- mtu
    |-- statistics
    |   |-- collisions
    |   |-- multicast
    |   |-- rx_bytes
    |   |-- rx_compressed
    |   |-- rx_crc_errors
    |   |-- rx_dropped
    |   |-- rx_errors
    |   |-- rx_fifo_errors
    |   |-- rx_frame_errors
    |   |-- rx_length_errors
    |   |-- rx_missed_errors
    |   |-- rx_over_errors
    |   |-- rx_packets
    |   |-- tx_aborted_errors
    |   |-- tx_bytes
    |   |-- tx_carrier_errors
    |   |-- tx_compressed
    |   |-- tx_dropped
    |   |-- tx_errors
    |   |-- tx_fifo_errors
    |   |-- tx_heartbeat_errors
    |   |-- tx_packets
    |   `-- tx_window_errors
    |-- tx_queue_len
    `-- type

6 directories, 66 files
