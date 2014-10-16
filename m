From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Netlink mmap tx security?
Date: Thu, 16 Oct 2014 06:52:47 +0100
Message-ID: <20141016055247.GA13475@casper.infradead.org>
References: <CALCETrWDSG2EhxBnM8Jm55Ov8PYQ_w3Wf88SKYOB1q1WgRpbEw@mail.gmail.com>
 <20141014.220111.179628329028952302.davem@davemloft.net>
 <543F0712.8080503@redhat.com>
 <20141015.195737.1429281929513331763.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dborkman@redhat.com, luto@amacapital.net,
	torvalds@linux-foundation.org, kaber@trash.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49636 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbaJPFwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2014 01:52:49 -0400
Content-Disposition: inline
In-Reply-To: <20141015.195737.1429281929513331763.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/14 at 07:57pm, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Thu, 16 Oct 2014 01:45:22 +0200
> 
> > On 10/15/2014 04:01 AM, David Miller wrote:
> >> From: Andy Lutomirski <luto@amacapital.net>
> >> Date: Tue, 14 Oct 2014 15:16:46 -0700
> >>
> >>> It's at least remotely possible that there's something that assumes
> >>> that assumes that the availability of NETLINK_RX_RING implies
> >>> NETLINK_TX_RING, which would be unfortunate.
> >>
> >> I already found one such case, nlmon :-/
> > 
> > Hmm, can you elaborate? I currently don't think that nlmon cares
> > actually.
> 
> nlmon cares, openvswitch cares, etc:
> 
> http://openvswitch.org/pipermail/dev/2013-December/034496.html

(Fortunately) the OVS patch has not been merged yet because the number
of Netlink sockets created per vport in the current architecture
currently make it a non scalable approach.

I think introdcing a NETLINK_RX_RING2 and having NETLINK_RX_RING fail
is not a bad way out of this.
