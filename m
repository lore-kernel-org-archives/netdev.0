From: "Jon Nelson" <jnelson@jamponi.net>
Subject: Re: [PATCH] via-velocity: don't oops on MTU change.
Date: Thu, 15 Nov 2007 20:42:55 -0600
Message-ID: <cccedfc60711151842l4aafe0ffo220e84a5e37b6a82@mail.gmail.com>
References: <20071114193844.0cab5c7d@freepuppy.rosehill>
	 <20071115082600.GA2366@ff.dom.local>
	 <20071115102005.0cf46f9a@freepuppy.rosehill> <473CD1F6.9030709@o2.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	jnelson-kernel-bugzilla@jamponi.net
To: "Jarek Poplawski" <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:31025 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934645AbXKPCnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 21:43:04 -0500
Received: by nf-out-0910.google.com with SMTP id g13so696708nfb
        for <netdev@vger.kernel.org>; Thu, 15 Nov 2007 18:43:01 -0800 (PST)
In-Reply-To: <473CD1F6.9030709@o2.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/15/07, Jarek Poplawski <jarkao2@o2.pl> wrote:
..

> Sure! I was only worried velocity_open() treats dev->mtu
> a bit different than velocity_change_mtu(), so eg. after:
>
> velocity_change_mtu() // dev is down
> velocity_open()
> velocity_change_mtu() // dev is up
>
> with the same mtu, vptr->rx_buf_sz could be different than after:
>
> velocity_open()
> velocity_change_mtu() // dev is up
>
> But, probably, I miss someting.

There is a snag here: if I change the MTU after the device is UP
something ends up rather broken. A tcpdump shows nearly every outgoing
frame has a bad TCP checksum (and the card does not support H/W
checksumming or it is turned off as reported by ethtool).

-- 
Jon
