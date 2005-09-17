From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance
Date: Fri, 16 Sep 2005 17:28:23 -0700
Message-ID: <20050917002823.GB19112@netnation.com>
References: <20050825200543.GA6612@yakov.inr.ac.ru> <20050825212211.GA23384@netnation.com> <20050826115520.GA12351@yakov.inr.ac.ru> <17167.29239.469711.847951@robur.slu.se> <20050906235700.GA31820@netnation.com> <17182.64751.340488.996748@robur.slu.se> <20050907162854.GB24735@netnation.com> <20050907195911.GA8382@yakov.inr.ac.ru> <20050913221448.GD15704@netnation.com> <17191.55685.861191.831981@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <17191.55685.861191.831981@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2005 at 10:04:21AM +0200, Robert Olsson wrote:

> 
> Simon Kirby writes:
> 
> 
>  > Sender: 367 Mbps, 717883 pps valid src/dst, 64 byte (Ethernet) packets
>  > 
>  > 2.4.27-rc1: 297 Mbps forwarded (w/idle time?!)
>  > 2.4.31: 296 Mbps forwarded (w/idle time?!)
>  > 2.6.13-rc6: 173 Mbps forwarded
> 
>  > Time permitting, I'd also like to run some profiles.  It's interesting
>  > to note that 2.6 is slower at forwarding even straight duplicate small
>  > packets.  We should definitely get to the bottom of that.
> 
>  Yes. This is single flow? Strange.
> 
>  Run a fixed size shot 10Mpkts pkts or so for both 2.4 and 2.6 and save 
>  /proc/interrupts, proc/net/softnetstat, netstat -i, tc -s qdisc to start with.

I got stuck in some mud again, but I was able to run a small oprofile.

nf_iterate was near the top even though the firewall was empty, so I
changed CONFIG_IP_NF_IPTABLES=y to CONFIG_IP_NF_IPTABLES=m (and didn't
load it).  Throughput went up from 173 Mbps to 232 Mbps...yikes. 
Conntrack was never compiled.  I'll do some more profiling when I get
a chance...

Simon-
