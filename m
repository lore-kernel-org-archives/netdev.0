From: "David S. Miller" <davem@redhat.com>
Subject: Re: bonding vs 802.3ad/Cisco EtherChannel link agregation
Date: Mon, 16 Sep 2002 14:17:30 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20020916.141730.20023507.davem@redhat.com>
References: <3D8648AE.DD498ECE@nortelnetworks.com>
	<20020916.140453.72638827.davem@redhat.com>
	<3D864B96.6D0D43F4@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, cacophonix@yahoo.com,
	linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: cfriesen@nortelnetworks.com
In-Reply-To: <3D864B96.6D0D43F4@nortelnetworks.com>
List-Id: netdev.vger.kernel.org

   From: Chris Friesen <cfriesen@nortelnetworks.com>
   Date: Mon, 16 Sep 2002 17:22:30 -0400

   I did see those posts, but then I saw yours on how the linux
   receive end does the right thing with regards to reordering, and
   that confused me.

It's a last ditch effort to keep receive performance on the TCP
connection reasonable, it is not meant to be a normal mode
of operation.  The reordering detection in the TCP stack does
not get you back to optimal receive performance, it simply can't.

For one thing, all of the fast paths in the TCP input paths require
that the packets arrive in order.

If bonding did what you suggest, reordering would become the norm
and that isn't going to be good for TCP input performance whether
we have reordering detection logic or not.
