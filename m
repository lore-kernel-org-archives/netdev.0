From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 04/10] AOE: use rcu to find network device
Date: Thu, 12 Nov 2009 11:09:21 -0800
Message-ID: <20091112110921.07a8412d@nehalam>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.409162953@vyatta.com>
	<8ffe0a1df67d13a45a413f40d00dd80a@coraid.com>
	<20091110150617.0e6920f0@nehalam>
	<20091110155316.2c3d7b6e@nehalam>
	<e160a17e366ae2f676df822db1e62bc2@coraid.com>
	<20091112091048.00d00d1b@nehalam>
	<054b5fbe4b446c6342704cd1bd5265db@coraid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ecashin@coraid.com, karaluh@karaluh.pl, roel.kluin@gmail.com,
	harvey.harrison@gmail.com, bzolnier@gmail.com,
	netdev@vger.kernel.org
To: Ed Cashin <ecashin@coraid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39152 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752806AbZKLTJm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2009 14:09:42 -0500
In-Reply-To: <054b5fbe4b446c6342704cd1bd5265db@coraid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Nov 2009 13:07:35 -0500
Ed Cashin <ecashin@coraid.com> wrote:

> Thanks for the responses.
> 
> On Thu Nov 12 12:11:12 EST 2009, shemminger@vyatta.com wrote:
> ...
> > Since it is emulating a block device, why not propgate error back
> > up the stack like a disk that's offline.
> 
> The lack of local interfaces to use for AoE might be temporary.  For
> example, the admin might be loading a new network driver, or a new
> link might go online through which the AoE target can be reached.
> 
> If AoE command packets are not sent or resent but instead are
> effectively dropped while there are no local interfaces through which
> to send, then the AoE commands will timeout through the normal
> mechanisms, at which time the error will be signaled to the block
> layer.  It will be like normal unreliable ethernet transport.
> 
> In the common case, I think that's going to be the expected behavior,
> but a printk would probably still be helpful in case the admin doesn't
> realize why the AoE device is timing out.
> 

Okay, you might want to ratelimit the printk

-- 
