From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: [PATCH 2.6] e100: use NAPI mode all the time
Date: Sun, 06 Jun 2004 17:03:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086566591.3721.54.camel@localhost.localdomain>
References: <Pine.LNX.4.58.0406041727160.2662@sfeldma-ich5.jf.intel.com>
	 <DC71FD1C-B80C-11D8-9557-000393652100@engr.uky.edu>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <scott.feldman@intel.com>, netdev@oss.sgi.com,
        bonding-devel@lists.sourceforge.net, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tim Mattox <tmattox@engr.uky.edu>
In-Reply-To: <DC71FD1C-B80C-11D8-9557-000393652100@engr.uky.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Have you considered how this interacts with multiple e100's bonded
> together with Linux channel bonding?
> I've CC'd the bonding developer mailing list to flush out any more
> opinions on this.

No.  But if there is an issue between NAPI and bonding, that's something
to solve between NAPI and bonding but not the nic driver.

> I have yet to set up a good test system, but my impression has been
> that NAPI and channel bonding would lead to lots of packet re-ordering
> load for the CPU that could outweigh the interrupt load savings.
> Does anyone have experience with this?

re-ordering or dropped?

> Also, depending on the setting of /proc/sys/net/ipv4/tcp_reordering
> the TCP stack might do aggressive NACKs because of a false-positive on
> dropped packets due to the large reordering that could occur with
> NAPI and bonding combined.

I guess I don't see the bonding angle.  How does inserting a SW FIFO
between the nic HW and the softirq thread make things better for
bonding?

> In short, unless there has been study on this, I would suggest not yet
> removing support for non-NAPI mode on any network driver.

fedora core 2's default is e100-NAPI, so we're getting good test
coverage there without bonding.   tg3 has used NAPI only for some time,
and I'm sure it's used with bonding.  

-scott
