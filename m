From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] netem: restart device after inserting packets
Date: Mon, 13 Dec 2004 11:08:28 -0800
Message-ID: <20041213110828.2af5d0e1@dxpl.pdx.osdl.net>
References: <20041208123103.4cc6b005@dxpl.pdx.osdl.net>
	<20041208210031.63f0963f.davem@davemloft.net>
	<41B91901.3070304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netem@osdl.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41B91901.3070304@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 10 Dec 2004 04:33:21 +0100
Patrick McHardy <kaber@trash.net> wrote:

> David S. Miller wrote:
> 
> >On Wed, 8 Dec 2004 12:31:03 -0800
> >Stephen Hemminger <shemminger@osdl.org> wrote:
> >  
> >
> >>The version of netem in 2.6.10 moves packets from the delayed queue
> >>to the qdisc in a timer interrupt. But it forgot to force the device to
> >>pick them up.
> >>
> >>Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> >>
> >
> >Good spotting.  Applied, thanks Stephen.
> >
> The patch is incomplete, netem may dequeue multiple packets from
> the delayed queue at once and feed them to the inner queue, but
> qdisc_restart will only dequeue one packet from the inner queue.
> This patch moves qdisc_run back to include/net/pkt_sched.h and
> replaces qdisc_restart by qdisc_run in netem_watchdog.

Yes, I wasn't running big enough delays to notice.
