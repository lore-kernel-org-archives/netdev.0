From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Mon, 09 Jun 2003 16:05:47 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609.160547.41648991.davem@redhat.com>
References: <20030609221911.GF11509@netnation.com>
	<008001c32eda$56760830$4a00000a@badass>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@netnation.com, hadi@shell.cyberus.ca, fw@deneb.enyo.de,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: xerox@foonet.net
In-Reply-To: <008001c32eda$56760830$4a00000a@badass>
List-Id: netdev.vger.kernel.org

   From: "CIT/Paul" <xerox@foonet.net>
   Date: Mon, 9 Jun 2003 18:56:18 -0400

   And there is no reason for NAPI at this point. 
   
Intel's ITR give you high latency, NAPI is far superior
than any hardware based interrupt mitigation scheme whatsoever.

You have some system specific problem with NAPI and we need
to analyze that.

   I've mucked with TONNnss of settings.. I've even had the route-cache up
   to over 600,000 entries and the CPU still has room left for more..
   It can't possibly be the size of the cache,

You are letting your hash chains reach the size of "max_size" divided
by the number of hash chains.

This means that every packet into your machine has to walk that
many hash chains.

You can keep doing some shamans dance saying that the size you
have choosen doesn't matter, but the people who have written
this code and work with it every day know that it does.
