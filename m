From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] via-velocity: don't oops on MTU change.
Date: Thu, 15 Nov 2007 20:05:20 -0800
Message-ID: <20071115200520.0a887abb@freepuppy.rosehill>
References: <20071114193844.0cab5c7d@freepuppy.rosehill>
	<20071115082600.GA2366@ff.dom.local>
	<20071115102005.0cf46f9a@freepuppy.rosehill>
	<473CD1F6.9030709@o2.pl>
	<cccedfc60711151842l4aafe0ffo220e84a5e37b6a82@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@o2.pl>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	jnelson-kernel-bugzilla@jamponi.net
To: "Jon Nelson" <jnelson@jamponi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48064 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756469AbXKPEHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 23:07:13 -0500
In-Reply-To: <cccedfc60711151842l4aafe0ffo220e84a5e37b6a82@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Nov 2007 20:42:55 -0600
"Jon Nelson" <jnelson@jamponi.net> wrote:

> On 11/15/07, Jarek Poplawski <jarkao2@o2.pl> wrote:
> ..
> 
> > Sure! I was only worried velocity_open() treats dev->mtu
> > a bit different than velocity_change_mtu(), so eg. after:
> >
> > velocity_change_mtu() // dev is down
> > velocity_open()
> > velocity_change_mtu() // dev is up
> >
> > with the same mtu, vptr->rx_buf_sz could be different than after:
> >
> > velocity_open()
> > velocity_change_mtu() // dev is up
> >
> > But, probably, I miss someting.
> 
> There is a snag here: if I change the MTU after the device is UP
> something ends up rather broken. A tcpdump shows nearly every outgoing
> frame has a bad TCP checksum (and the card does not support H/W
> checksumming or it is turned off as reported by ethtool).
> 

That is a different (and pre-existing bug). 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
