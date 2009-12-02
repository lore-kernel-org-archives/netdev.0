From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute: "ip mroute show" doesn't show all output
 interfaces
Date: Tue, 1 Dec 2009 16:16:48 -0800
Message-ID: <20091201161648.250638fb@nehalam>
References: <20091123095231.GA14210@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mark Borst <mark@borst.org>
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43845 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754755AbZLBARF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2009 19:17:05 -0500
In-Reply-To: <20091123095231.GA14210@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Nov 2009 10:52:31 +0100
Andreas Henriksson <andreas@fatal.se> wrote:

> From: Mark Borst <mark@borst.org>
> 
> The command "ip mroute show" will only show the first Oif. 
> 
> mark@flappie:~$ ip mroute show
> (192.168.1.1, 224.0.0.123)       Iif: _rename    Oifs: eth1 
> 
> mark@flappie:~$ cat /proc/net/ip_mr_cache 
> Group    Origin   Iif     Pkts    Bytes    Wrong Oifs
> 7B0000E0 0101A8C0 2          0        0        0  0:1    1:1  
> 
> This shows 2 Oifs here. However, ipmroute.c, function read_mroute_list(), uses sscanf() with a %s mask for oiflist, which stops after the first whitespace (i.e. after Oif 0:1). The patch below fixes this to read until the newline (though I'm not sure whether this is the proper way to fix it).
> 
> After this patch:
> mark@flappie:~/iproute-20090324/ip$ ./ip mroute show
> (192.168.1.1, 224.0.0.123)       Iif: _rename    Oifs: eth1 eth0 
> 
> 
> This patch originally submitted as http://bugs.debian.org/550097
> 
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>

Applied with small modification, sscanf... %u%[^\n] would not
skip leading whitespace like the original %u%s but adding a blank
in the format will correct that.

-- 
