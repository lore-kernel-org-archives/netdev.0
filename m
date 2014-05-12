From: Peter Christensen <pch@ordbogen.com>
Subject: Re: [PATCH] macvlan: Don't propagate IFF_ALLMULTI changes on down
 interfaces.
Date: Mon, 12 May 2014 09:59:53 +0200
Message-ID: <20140512095953.076bd76d@pch.odense.ordbogen.com>
References: <1399540537-19262-1-git-send-email-pch@ordbogen.com>
	<20140509.160225.1543592257804345860.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ordbogen.com ([86.58.170.13]:33260 "EHLO mail.ordbogen.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752938AbaELIAG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2014 04:00:06 -0400
In-Reply-To: <20140509.160225.1543592257804345860.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 09 May 2014 16:02:25 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Peter Christensen <pch@ordbogen.com>
> Date: Thu,  8 May 2014 11:15:37 +0200
> 
> > Clearing the IFF_ALLMULTI flag on a down interface could cause an
> > allmulti overflow on the underlying interface.
> > 
> > Attempting the set IFF_ALLMULTI on the underlying interface would
> > cause an error and the log message:
> > 
> > "allmulti touches root, set allmulti failed."
> > 
> > Signed-off-by: Peter Christensen <pch@ordbogen.com>
> 
> Hmmm, but won't we lose this event once the interface is brought
> back up?

No, macvlan_open and macvlan_stop already takes care of that (which is
part of the reason the allmulti counter overflowed). Either
macvlan_open and macvlan_close shouldn't touch the flag on the
underlying interface, or
macvlan_change_rx_flags shouldn't touch the underlying interface if the
MACVLAN interface is down.

I though that it was probably better to make MACVLAN as non-intrusive
to the underlying interface when the MACVLAN interface is down, so I
opted for this solution.

Apparently the 802.1Q VLAN driver behaves
exactly like that, and back in 2011 it got a patch similar to this one
(commit deede2fabe24e00bd7e246eb81cd5767dc6fcfc7).
