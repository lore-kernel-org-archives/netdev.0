From: Ben Greear <greearb@candelatech.com>
Subject: packet sockets and dev_get_by_name
Date: Wed, 16 Oct 2002 00:13:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DAD118A.6090000@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It appears that the the

  static int packet_sendmsg_spkt(struct socket *sock, struct msghdr *msg, int len,
			       struct scm_cookie *scm)

method in net/packet/af_packet.c does a dev_get_by_name on each packet sent.
...
	/*
	 *	Find the device first to size check it
	 */

	saddr->spkt_device[13] = 0;
	dev = dev_get_by_name(saddr->spkt_device);
	err = -ENODEV;
	if (dev == NULL)
		goto out_unlock;

The packet_sendmsg does a dev_get_by_index, which is also a linear walk...


Think it would be worth optimizing this?  Seems if we hashed devices
on their index, and then (for packet_sendmsg_spkt) cached the last device
we found for a name in the socket, we could make this more like O(1).

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
