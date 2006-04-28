From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [LARTC] how to change classful netem loss probability?
Date: Fri, 28 Apr 2006 10:24:21 -0700
Message-ID: <20060428102421.7d304ca6@localhost.localdomain>
References: <444FF846.7050600@cmu.edu>
	<32923.128.2.140.234.1146187103.squirrel@128.2.140.234>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "George Nychis" <gnychis@cmu.edu>, lartc@mailman.ds9a.nl,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:13476 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030461AbWD1RY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 13:24:27 -0400
To: "George P Nychis" <gnychis@cmu.edu>
In-Reply-To: <32923.128.2.140.234.1146187103.squirrel@128.2.140.234>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Loss was broken, patch sent.

The following works now:

# tc qdisc add dev eth1 root handle 1:0 netem loss 20%

# tc qdisc add dev eth1 parent 1:1 handle 10: tbf \
  rate 256kbit buffer 1600 limit 3000
# ping -f -c 1000 shell

1000 packets transmitted, 781 received, 21% packet loss, time 3214ms
rtt min/avg/max/mdev = 0.187/0.398/3.763/0.730 ms, ipg/ewma 3.217/0.538 ms

# tc qdisc chang dev eth1 handle 1: netem loss 1%
# ping -f -c 1000 shell

1000 packets transmitted, 990 received, 1% packet loss, time 2922ms
rtt min/avg/max/mdev = 0.187/2.739/3.298/0.789 ms, ipg/ewma 2.924/2.084 ms


