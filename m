From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: bonding vs 802.3ad/Cisco EtherChannel link agregation
Date: Mon, 16 Sep 2002 17:10:06 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3D8648AE.DD498ECE@nortelnetworks.com>
References: <20020913222213.69396.qmail@web14006.mail.yahoo.com>
		<3D85DB3D.DC65A80B@nortelnetworks.com>
		<3D860246.3060609@candelatech.com> <20020916.125555.36549381.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, cacophonix@yahoo.com,
	linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org

"David S. Miller" wrote:

> There is a lot of logic in our TCP input btw that notices packet
> reordering on the receive side and acts accordingly (ie. it does not
> fire off fast retransmits or backoff prematurely when reordering
> is detected)

Okay, that makes me even more curious why we don't send successive packets out successive pipes in a
bonded link.

It seems to me that when sending packets out a bonded link, we should scan for the next device that
has an opening on its queue (perhaps also taking into account link speed etc) so as to try and keep
the entire aggregate link working at max capacity.

Does this not make sense in the real world for some reason?  Maybe a config option
CONFIG_MAX_BONDED_THROUGHPUT to allow a single stream to take up the entire aggregate link even if
it makes the receiver do more work?

Chris
