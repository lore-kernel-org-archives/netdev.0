From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6] update to network emulation QOS scheduler
Date: Tue, 6 Jul 2004 09:09:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706090906.4ff6fb73@dell_ss3.pdx.osdl.net>
References: <20040701113312.43cfe6c5@dell_ss3.pdx.osdl.net>
	<20040702134437.5891e998@dell_ss3.pdx.osdl.net>
	<1088824432.1043.271.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, Catalin BOIE
 <util@deuroconsult.ro>,
        netdev@oss.sgi.com, lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1088824432.1043.271.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 02 Jul 2004 23:13:52 -0400
jamal <hadi@cyberus.ca> wrote:

> On Fri, 2004-07-02 at 16:44, Stephen Hemminger wrote:
> > Here is an enhancement to netem to do allow emulating lower speed 
> > networks.  The resolution is close, but obviously limited by the
> > granularity of timers and size of packets.
> > 
> > Also, fixes a rtnetlink dependency which showed up in some configurations
> > and optimizes for the non-loss case by avoiding net_random call.
> > 
> 
> I think its time i illustrate my comments earlier with some example
> hopefully this will curb the amount of features on this qdisc.
> I do think theres value in having this thing do delay and jitter, but
> you have gone waay beyond that now; 
> Let illustrate things which apply to what you are trying to do in
> network condituions emulation. Although i show ingress qdisc , this
> applies to egress just the same.
> 
> #drop 1 out 10 packets randomly using the netrand generator
> tc filter add dev eth0 parent ffff: protocol ip prio 6 u32 \
> match ip src 10.0.0.21/32 flowid 1:16 \
> action drop random netrand ok 0xa

Your examples made me think about this more.  The netfilter seem best
suited to things that effect the flow of packets (dropping, reordering,
even corrupting), and the qdisc seems best when the timing needs to change.

The limit match in netfilter is not the same as the rate in the qdisc.
The netem scheduler acts as if the link is a slow fixed rate.  The netfilter
limit is usually targeted to drop packets over the rate which is not the same.
Reordering is also hard without going out to a user log or building a custom
target.

So, you have convinced me that loss is unnecessary but not the rate, or delay.
If we can figure out how to re-ordering with netfilter then that could go too,
which would make it possible to use a layered qdisc again.
