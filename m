From: jamal <hadi@cyberus.ca>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
	Topics
Date: 29 Mar 2005 18:30:00 -0500
Message-ID: <1112139000.1091.44.camel@jzny.localdomain>
References: <20050327054831.GA15453@waste.org>
	 <1111905181.4753.15.camel@mylaptop>
	 <20050326224621.61f6d917.davem@davemloft.net>
	 <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com>
	 <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave>
	 <20050329152008.GD63268@muc.de> <1112116762.5088.65.camel@beastie>
	 <1112130512.1077.107.camel@jzny.localdomain>
	 <Pine.LNX.4.61.0503291659290.15625@chimarrao.boston.redhat.com>
	 <20050329221743.GK15453@waste.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rik van Riel <riel@redhat.com>, Dmitry Yusupov <dmitry_yus@yahoo.com>,
        Andi Kleen <ak@muc.de>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        andrea@suse.de, michaelc@cs.wisc.edu, open-iscsi@googlegroups.com,
        ksummit-2005-discuss@thunk.org, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20050329221743.GK15453@waste.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-03-29 at 17:17, Matt Mackall wrote:

> I'm sure Rik realizes this, but it's important to note here that
> "making progress" may require M acknowledgements to N packets
> representing a single IO. So we need separate send and acknowledge
> pools for each SO_MEMALLOC socket so that we don't find ourselves
> wedged with M-1 available mempool slots when we're waiting on ACKs. So
> accounting ACK packets to the appropriate receiver once we've figured
> out what socket an ACK is intended for is critical.
> 

Is this idea discussed or posted somewhere? I just subscribed to the
list.
Sounds like what the NICs i described do on rx - some strict priority
scheme.
Seems to me the TX side needs to be done early perhaps at the socket
layer.
The RX side needs to be done at the NIC or ingress qdisc.

I think there may be need for multiple levels of granularity of
priorities for mem allocation pools 8 or more if you want to have 
different levels of importantance in apps.
The deal with strict prio is the most important apps can eat all the
memory if they needed it; so you may need some form of deficit based
scheduling or kick in the algorithm only when a certain threshold is 
crossed system wide.

> Note that ACK here is the application layer command result that needs
> to be propagated back to the driver (and possibly higher in the case
> of things like CD writing over iSCSI) and not simply a bit in the TCP
> header.

I got that (given TCP is stream based).

cheers,
jamal
