From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] dummy -- support hardware address
Date: Thu, 8 Apr 2004 14:54:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040408145403.34382c96.davem@redhat.com>
References: <20040408110834.2fd1bd25@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040408110834.2fd1bd25@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Stephen, why don't you do what usbnet does?  Look at usbnet_init()
where it goes:

	get_random_bytes (node_id, sizeof node_id);
	node_id [0] &= 0xfe;	// clear multicast bit
	node_id [0] |= 0x02;    // set local assignment bit (IEEE802)

I distinctly remember Alan Cox saying this was the right way
do this and avoid conflicts with Vendor assigned IDs.
