From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make IP_MULTICAST_ALL and IP_MSFILTER work on raw
 sockets
Date: Sun, 20 Jul 2014 21:27:28 -0700 (PDT)
Message-ID: <20140720.212728.2235972803070688024.davem@davemloft.net>
References: <1405701503.3485.49.camel@samson1.armitage.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: quentin@armitage.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405701503.3485.49.camel@samson1.armitage.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Quentin Armitage <quentin@armitage.org.uk>
Date: Fri, 18 Jul 2014 17:38:23 +0100

> Currently, although IP_MULTICAST_ALL and IP_MSFILTER ioctl calls succeed on
> raw sockets, there is no code to implement the functionality on received
> packets; it is only implemented for UDP sockets. The raw(7) man page states:
> "In addition, all ip(7) IPPROTO_IP socket options valid for datagram sockets
> are supported", which implies these ioctls should work on raw sockets.
> 
> To fix this, add a call to ip_mc_sf_allow on raw sockets.
> 
> This should not break any existing code, since the current position of
> not calling ip_mc_sf_filter makes it behave as if neither the IP_MULTICAST_ALL
> nor the IP_MSFILTER ioctl had been called. Adding the call to ip_mc_sf_allow
> will therefore maintain the current behaviour so long as IP_MULTICAST_ALL and
> IP_MSFILTER ioctls are not called. Any code that currently is calling
> IP_MULTICAST_ALL or IP_MSFILTER ioctls on raw sockets presumably is wanting
> the filter to be applied, although no filtering will currently be occurring.
> 
> Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>

Please form your subject line properly, the text should be of the form:

[PATCH] ${SUBSYSTEM}: Description.

Your's is missing the subsystem prefix, which should probable be "ipv4: "
in this case.
