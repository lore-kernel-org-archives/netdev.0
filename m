From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] TCP Vegas for 2.6
Date: Mon, 8 Mar 2004 13:30:09 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040308133009.1e068199@dell_ss3.pdx.osdl.net>
References: <20040308130454.0442c04d@dell_ss3.pdx.osdl.net>
	<20040308212156.GE26401@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net <linux-net@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040308212156.GE26401@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 8 Mar 2004 22:21:56 +0100
Andi Kleen <ak@suse.de> wrote:

> > +/* Vegas variables */
> > +	struct {
> > +		__u32	beg_snd_nxt;	/* right edge during last RTT */
> > +		__u32	beg_snd_una;	/* left edge  during last RTT */
> > +		__u32	beg_snd_cwnd;	/* saves the size of the cwnd */
> > +		__u8	do_vegas;	/* do vegas for this connection */
> > +		__u8	doing_vegas_now;/* if true, do vegas for this RTT */
> > +		__u16	cntRTT;		/* # of RTTs measured within last RTT */
> > +		__u32	minRTT;		/* min of RTTs measured within last RTT (in usec) */
> > +		__u32	baseRTT;	/* the min of all Vegas RTT measurements seen (in usec) */
> > +	} vegas;
> 
> How about making this and the experimental westwood stuff CONFIG_* 
> options? At least for the data structures?  Or maybe alternatively allocating
> it separately when needed only (this would avoid CONFIG_* options)

CONFIG options are of no use vendors who need to ship binary kernels.

But it might make sense to drop this for CONFIG_EMBEDDED, but I can't
see embedded kernels having lots of connections anyway.

> I remember when we made jokes about the size of TCBs of other stacks 
> compared to Linux, but we must have exceeded them all by far. The additional
> code is not really a problem, but adding all that bloat to dynamic data 
> structures adds up quickly when you have a few thousands of them, limiting
> scalability.
> 
> -Andi


-- 
Stephen Hemminger 		mailto:shemminger@osdl.org
Open Source Development Lab	http://developer.osdl.org/shemminger
