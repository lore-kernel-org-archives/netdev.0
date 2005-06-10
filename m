From: "David S. Miller" <davem@davemloft.net>
Subject: Re: BCM5704 performance questions.
Date: Thu, 09 Jun 2005 18:29:43 -0700 (PDT)
Message-ID: <20050609.182943.29573731.davem@davemloft.net>
References: <42A8E0FE.3020708@candelatech.com>
	<20050609.175417.108740435.davem@davemloft.net>
	<42A8EAE1.5030201@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com
In-Reply-To: <42A8EAE1.5030201@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Thu, 09 Jun 2005 18:20:33 -0700

> I ran a test using pktgen to (try to) send 82kpps, 1514 byte packets between
> two ports on the tg3 NIC.  It can do about 780Mbps in one direction,
> and 880Mbps in the other direction.  Lots of harmless hard-start xmit errors reported
> (tg3 may not stop it's tx queue correctly, or maybe pktgen is screwed up since
> e1000 reports similar errors).

There is a known race on SMP with drivers using NETIF_F_LLTX that is
still not fixed.  It will cause the error message to be reported from
the driver's ->hard_start_xmit() routine when you hit this race.

The e1000 driver hits the same race, it just doesn't print any
message.

You're definitely on an SMP system if you are triggering that message.
