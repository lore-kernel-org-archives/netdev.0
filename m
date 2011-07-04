From: Alexander Stein <alexander.stein@systec-electronic.com>
Subject: Re: possible bridge regression in "bridge: implement [add/del]_slave ops"?
Date: Mon, 4 Jul 2011 08:46:44 +0200
Message-ID: <201107040846.45016.alexander.stein@systec-electronic.com>
References: <201106301033.23997.alexander.stein@systec-electronic.com> <20110630100819.0e4b536f@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 61-96-236-77.server-home.net ([77.236.96.61]:40024 "EHLO
	webbox1416.server-home.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752667Ab1GDGwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 02:52:51 -0400
In-Reply-To: <20110630100819.0e4b536f@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 30 June 2011 19:08:19 Stephen Hemminger wrote:
> On Thu, 30 Jun 2011 10:33:23 +0200
> 
> Alexander Stein <alexander.stein@systec-electronic.com> wrote:
> > * echo $(pgrep rstpd) > /var/run/rstpd.pid
> > * brctl addbr br1
> > * echo 1 > /sys/class/net/br1/bridge/stp_state
> 
> This bogus. You are running both kernel and spanning
> tree daemon at the same time!
> 
> Doing the echo of 1 to stp_state forces kernel spanning
> tree. You want 2 which is what is supposed to be use for user
> mode spanning tree.

Well, at first sight you're right. But looking at the code at 
br_stp_set_enabled() in br_stp_if.c it doesn't matter which value you echo 
into stp_state, it just have to be non-zero
The detection of usermode oder kernelmode STP is done using the usermode 
helper (see br_stp_start). I tried echoing 1, 2 or even 5 into stp_state, with 
a working /sbin/bridge-stp I get 2 from stp_state each time.

Maybe it is valuable to change this odd behavior.

Regards,
Alexander
