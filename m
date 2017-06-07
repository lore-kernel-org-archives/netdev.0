From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/16] nfp: ctrl vNIC
Date: Wed, 07 Jun 2017 12:52:26 -0400 (EDT)
Message-ID: <20170607.125226.955748734442639202.davem@davemloft.net>
References: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60000 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750831AbdFGQwb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 12:52:31 -0400
In-Reply-To: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Mon,  5 Jun 2017 17:01:41 -0700

> This series adds the ability to use one vNIC as a control channel
> for passing messages to and from the application firmware.  The
> implementation restructures the existing netdev vNIC code to be able
> to deal with nfp_nets with netdev pointer set to NULL.  Control vNICs
> are not visible to userspace (other than for dumping ring state), and
> since they don't have netdevs we use a tasklet for RX and simple skb 
> list for TX queuing.
> 
> Due to special status of the control vNIC we have to reshuffle the
> init code a bit to make sure control vNIC will be fully brought up
> (and therefore communication with app FW can happen) before any netdev
> or port is visible to user space.
> 
> FW will designate which vNIC is supposed to be used as control one
> by setting _pf%u_net_ctrl_bar symbol.  Some FWs depend on metadata
> being prepended to control message, some prefer to look at queue ID
> to decide that something is a control message.  Our implementation
> can cater to both.
> 
> First two users of this code will be eBPF maps and flower offloads.

Ok, I read this over and also checked out your discussion with Jiri.
So far this looks OK to me, so series applied.

I look forward to seeing the eBPF maps and flower follow-on stuff.
