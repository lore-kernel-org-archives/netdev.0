From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [CRIU] TCP_REPAIR MSS issue
Date: Tue, 14 Jun 2016 06:10:02 -0700
Message-ID: <1465909802.7945.183.camel@edumazet-glaptop3.roam.corp.google.com>
References: <C6D17923-7965-4483-8604-C654BFF1E0FF@netapp.com>
	 <575FEA4B.2000603@virtuozzo.com>
	 <3758708E-B5DE-4D8B-A8CC-37346F994B32@netapp.com>
	 <1465909415.7945.182.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@virtuozzo.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"criu@openvz.org" <criu@openvz.org>,
	Andrey Vagin <avagin@virtuozzo.com>,
	"Honda, Michio" <michio@netapp.com>
To: "Eggert, Lars" <lars@netapp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35654 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346AbcFNNKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 09:10:05 -0400
Received: by mail-io0-f195.google.com with SMTP id n127so20547070iof.2
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 06:10:05 -0700 (PDT)
In-Reply-To: <1465909415.7945.182.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-06-14 at 06:03 -0700, Eric Dumazet wrote:
> On Tue, 2016-06-14 at 11:40 +0000, Eggert, Lars wrote:
> > On 2016-06-14, at 13:28, Pavel Emelyanov <xemul@virtuozzo.com> wrote:
> > > Andrey (in Cc) has played with TCP_REPAIR recently, I guess he can know something.
> > 
> > Thanks for CC'ing him. We looked a little bit more into this:
> > 
> > When TCP_REPAIR is on, tcp_connect() directly calls tcp_finish_connect() before returning, passing NULL for skb, which causes sk_rx_dst_set() to be bypassed. Later, when TCP_REPAIR is being turned off, do_tcp_setsockopt() just does tcp_send_window_probe(), but apparently all the "dst" stuff is being bypassed then also, so the mss remains at TCP_MSS_DEFAULT.
> > 
> > Lars
> 
> What gives :
> 
> sysctl net/ipv4/ip_no_pmtu_disc net/ipv4/tcp_mtu_probing
> 

Also, is it a regression ? Was this working better with an older linux
version ?
