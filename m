From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 2/2] ipv4 igmp: use del_timer_sync instead of del_timer
 in ip_mc_down
Date: Thu, 5 Sep 2013 08:43:12 -0700
Message-ID: <20130905084312.091f73b7@nehalam.linuxnetplumber.net>
References: <1378363404-37749-1-git-send-email-noureddine@aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Salam Noureddine <noureddine@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:49614 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936Ab3IEPnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 11:43:16 -0400
Received: by mail-pa0-f44.google.com with SMTP id fz6so2077772pac.17
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 08:43:15 -0700 (PDT)
In-Reply-To: <1378363404-37749-1-git-send-email-noureddine@aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  4 Sep 2013 23:43:24 -0700
Salam Noureddine <noureddine@aristanetworks.com> wrote:

> Delete timers using del_timer_sync in ip_mc_down. Otherwise, it is
> possible for the timer to be the last to release its reference to the
> in_device and since __in_dev_put doesn't destroy the in_device we
> would end up leaking a reference to the net_device and see messages
> like the following,
> 
> unregister_netdevice: waiting for eth0 to become free. Usage count = 1
> 
> Tested on linux-3.4.43.
> 
> Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>

Why not just call in_dev_put instead which just proper cleanup.
It is less risky of deadlock than del_timer_sync.
