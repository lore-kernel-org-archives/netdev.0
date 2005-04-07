From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2/5] TCP BIC 1.1 support
Date: Thu, 7 Apr 2005 12:02:38 -0700
Message-ID: <20050407120238.47f953fb@dxpl.pdx.osdl.net>
References: <20050318162211.366ca490@dxpl.pdx.osdl.net>
	<423B9415.2010906@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@digeo.com>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com, Injong Rhee <rhee@eos.ncsu.edu>
Return-path: <netdev-bounce@oss.sgi.com>
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: <423B9415.2010906@ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 19 Mar 2005 02:53:09 +0000
Baruch Even <baruch@ev-en.org> wrote:

> Stephen Hemminger wrote:
> > This patch adds TCP BIC back in as a pluggable TCP congestion mechanism.
> > This version is closer to the TCP BIC 1.1 released for Web100.
> > The changes from 2.6.11 are:
> > 	* congestion window undo fix
> > 	* delayed ack compensation

The delayed ack calculation code in this patch sequence doesn't work quite right.
It over estimates the number of delayed acks and this causes BIC to clamp down
too hard.  I'll look into it later, but just wanted to let people know that it
this version of BIC performs worse under delay. The problem is in the calculation
of ack_ratio not in the BIC portion.
