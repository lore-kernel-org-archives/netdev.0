From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Netlink, route monitoring, RTM_DELROUTE not issued for ppp peer
 address. Bug or feature?
Date: Mon, 16 Apr 2012 14:00:33 -0700
Message-ID: <20120416140033.6a6c0f45@nehalam.linuxnetplumber.net>
References: <8986ed37b55c756ecdeec0315f73e63a@visp.net.lb>
	<023e01cd197d$a9faba40$fdf02ec0$@no>
	<3db49d4a58321a5e185cd67335a60c81@visp.net.lb>
	<20120416081954.1bb994db@nehalam.linuxnetplumber.net>
	<9c375f4b88835bcde92bf3ba8f3434cc@visp.net.lb>
	<2f6d1271c8c6811acbbc5b2603c72115.squirrel@nlc.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Denys Fedoryshchenko" <denys@visp.net.lb>, eric.dumazet@gmail.com,
	stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: "Stian Skjelstad" <stian@nixia.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42684 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754567Ab2DPVAi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2012 17:00:38 -0400
In-Reply-To: <2f6d1271c8c6811acbbc5b2603c72115.squirrel@nlc.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Apr 2012 22:21:46 +0200
"Stian Skjelstad" <stian@nixia.no> wrote:

> > It looks like "correct" behavior should not harm existing programs that
> > much (just there will be netlink message to delete route that are
> > already deleted by program, e.g. quagga), but looking to code,
> > implementing this feature will make significant overhead and in some
> > cases it can be harmful.
> > For example if full view BGP interface dropped, it is hundreds of
> > thousands netlink messages. So seems better i will listen to
> > address/link changes also and keep routing table in memory.
> > So better seems to keep as is.
> 
> If I understand correct, the "missing" RTM_DELROUTE messages actually
> comes from something similar to "ip route flush dev eth0".
> 
> If the amount of traffic is a worry, couldn't there be a RTM_FLUSHROUTE or
> a special RTM_DELROUTE message that tells that all routes for a given
> device is removed?
> 

No. new message type would confuse all the things that listen now.
