From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC 0/2] pm,net: Introduce QoS requests per CPU
Date: Tue, 25 Mar 2014 08:14:07 -0700
Message-ID: <1395760447.12610.132.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395753505-13180-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, linux-pm@vger.kernel.org,
	netdev@vger.kernel.org, Pavel Machek <pavel@ucw.cz>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Len Brown <len.brown@intel.com>, yuvali@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>, idos@mellanox.com
To: Amir Vadai <amirv@mellanox.com>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <1395753505-13180-1-git-send-email-amirv@mellanox.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-03-25 at 15:18 +0200, Amir Vadai wrote:

> The current pm_qos implementation has a problem. During a short pause in a high
> bandwidth traffic, the kernel can lower the c-state to preserve energy.
> When the pause ends, and the traffic resumes, the NIC hardware buffers may be
> overflowed before the CPU starts to process the traffic due to the CPU wake-up
> latency.

This is the point I never understood with mlx4

RX ring buffers should allow NIC to buffer quite a large amount of
incoming frames. But apparently we miss frames, even in a single TCP
flow. I really cant understand why, as sender in my case do not have
more than 90 packets in flight (cwnd is limited to 90)

# ethtool -S eth0 | grep error
     rx_errors: 268
     tx_errors: 0
     rx_length_errors: 0
     rx_over_errors: 40
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_fifo_errors: 40
     rx_missed_errors: 40
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0
# ethtool -g eth0
Ring parameters for eth0:
Pre-set maximums:
RX:		8192
RX Mini:	0
RX Jumbo:	0
TX:		8192
Current hardware settings:
RX:		4096
RX Mini:	0
RX Jumbo:	0
TX:		4096




