From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3 net 2/9] bridge: Fix the way to insert new local fdb
 entries in br_fdb_changeaddr
Date: Fri, 7 Feb 2014 09:31:27 -0700
Message-ID: <20140207093127.56f78187@samsung-9>
References: <1391759306-24956-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<1391759306-24956-3-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:45433 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbaBGQbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 11:31:34 -0500
Received: by mail-pd0-f170.google.com with SMTP id p10so3371077pdj.1
        for <netdev@vger.kernel.org>; Fri, 07 Feb 2014 08:31:34 -0800 (PST)
In-Reply-To: <1391759306-24956-3-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  7 Feb 2014 16:48:19 +0900
Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:

> Since commit bc9a25d21ef8 ("bridge: Add vlan support for local fdb entries"),
> br_fdb_changeaddr() has inserted a new local fdb entry only if it can
> find old one. But if we have two ports where they have the same address
> or user has deleted a local entry, there will be no entry for one of the
> ports.
> 
> Example of problematic case:
>   ip link set eth0 address aa:bb:cc:dd:ee:ff
>   ip link set eth1 address aa:bb:cc:dd:ee:ff
>   brctl addif br0 eth0
>   brctl addif br0 eth1 # eth1 will not have a local entry due to dup.

I think the second addif should fail, it doesn't seem valid to have
two interfaces on same bridge with same address. Most hardware switches
would disable the port in that case.
