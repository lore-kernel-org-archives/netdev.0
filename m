From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]: was Re: LLTX and netif_stop_queue
Date: Wed, 26 Jan 2005 23:22:27 -0800
Message-ID: <20050126232227.3ce4decb.davem@davemloft.net>
References: <20050119144711.3fdd3d93.davem@davemloft.net>
	<20050119151853.259de49a@dxpl.pdx.osdl.net>
	<20050119164640.6c67bdfa.davem@davemloft.net>
	<52r7kgu5n5.fsf@topspin.com>
	<20050119230526.393a5184.davem@davemloft.net>
	<20050120085611.33f9485e@dxpl.pdx.osdl.net>
	<20050121105452.GA12988@xi.wantstofly.org>
	<20050125222705.1ee878fd.davem@davemloft.net>
	<20050126132512.GA18220@xi.wantstofly.org>
	<20050126223247.3e4643cc.davem@davemloft.net>
	<20050127071645.GA2731@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, shemminger@osdl.org, roland@topspin.com,
        hadi@cyberus.ca, iod00d@hp.com, eric.lemoine@gmail.com,
        netdev@oss.sgi.com, ak@suse.de, openib-general@openib.org,
        kaber@trash.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20050127071645.GA2731@wotan.suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 Jan 2005 08:16:45 +0100
Andi Kleen <ak@suse.de> wrote:

> > Yes, that's the idea.
> 
> per CPU only works in preemptive kernel if you have preemption
> disabled all the time. Do you? 
> 
> Seems not likely to me.

BH is disabled in these code paths (specifically we're talking
about ->hard_start_xmit()), as that is where the recursion
check goes.

Otherwise, loopback's LLTX is broken as it relies on this property
as well.
