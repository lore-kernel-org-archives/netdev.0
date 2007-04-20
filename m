From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH -mm take4 2/6] support multiple logging
Date: Fri, 20 Apr 2007 11:15:26 -0700
Message-ID: <20070420111526.01ad7f4c.akpm@linux-foundation.org>
References: <462605DC.2080804@bx.jp.nec.com>
	<462609D1.50300@bx.jp.nec.com>
	<20070419210813.a599c54f.akpm@linux-foundation.org>
	<46288D11.4000801@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Keiichi KII <k-keiichi@bx.jp.nec.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S2993311AbXDTSP7@vger.kernel.org>
In-Reply-To: <46288D11.4000801@bx.jp.nec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 20 Apr 2007 18:51:13 +0900
Keiichi KII <k-keiichi@bx.jp.nec.com> wrote:

> > I started to do some cleanups and fixups here, but abandoned it when it was
> > all getting a bit large.
> > 
> > Here are some fixes against this patch:
> 
> I'm going to fix my patches by following your reviews and send new patches 
> on the LKML and the netdev ML in a few days.
> 

Well..  before you can finish this work we need to decide upon what the
interface to userspace will be.

- The miscdev isn't appropriate

- netlink remains a possibility

- Stephen suggests an ioctl against a socket and davem suggests socket
  options, but it's unclear to me how that socket will get bound to
  netconsole?


either way, I agree with the overall thrust of this work: netconsole is
useful in production environments, can become more useful and will need
runtime configurability.


I wonder if we're approaching this in the right way, however...

At a high level, netconsole is just a flow of UDP packets between two
machines.  The kernel already has rich and well-understood ways of creating
and configuring such flows.

So...  instead of creating a brand new way of configuring such a flow via
sysfs and ioctl, could we instead create a flow using the existing
mechanisms (presumably the socket API) and then "transfer" the information
from that flow over to netconsole by some means??
