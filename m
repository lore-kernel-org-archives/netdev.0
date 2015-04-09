From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: "tcp: refine TSO autosizing" causes performance regression on
 Xen
Date: Thu, 09 Apr 2015 10:07:05 -0700
Message-ID: <1428599225.25985.267.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1504091344260.7690@kaball.uk.xensource.com>
	 <1428596218.25985.263.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1504091729160.7690@kaball.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	christoffer.dall@linaro.org,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>, edumazet@google.com,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	netdev <netdev@vger.kernel.org>
To: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1504091729160.7690@kaball.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-04-09 at 17:36 +0100, Stefano Stabellini wrote:

> A very big difference:
> 
> echo 262144 > /proc/sys/net/ipv4/tcp_limit_output_bytes
> brings us much closer to the original performance, the slowdown is just
> 8%

Cool.

> 
> echo 1048576 > /proc/sys/net/ipv4/tcp_limit_output_bytes
> fills the gap entirely, same performance as before "refine TSO
> autosizing"


Sure, this basically disables TCP Small Queue and select the opposite :

Favor single flow throughput and huge latencies (bufferbloat)


> 
> 
> What would be the next step for here?  Should I just document this as an
> important performance tweaking step for Xen, or is there something else
> we can do?

I guess this is a reasonable choice.

Note that /proc/sys/net/ipv4/tcp_limit_output_bytes is already
documented.
