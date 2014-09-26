From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] dql: dql_queued() should write first to reduce
 bus transactions
Date: Fri, 26 Sep 2014 05:02:55 -0700
Message-ID: <1411732975.16953.106.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140924160932.9721.56450.stgit@localhost>
	 <20140924161047.9721.43080.stgit@localhost>
	 <1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140924195831.6fb91051@redhat.com>
	 <CA+mtBx8s63TDe1XS7TzfscwhiRCgyeLkKLz2p-4et1erX0-dUQ@mail.gmail.com>
	 <1411586550.15395.46.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411611140.16953.1.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411688409.16953.64.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411711496.16953.92.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411729595.1776139.172032293.6FCC3EBB@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Toke =?ISO-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>,
	Florian Westphal <fw@strlen.de>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Dave Taht <dave.taht@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:39344 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753986AbaIZMC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 08:02:57 -0400
Received: by mail-pd0-f174.google.com with SMTP id g10so12288783pdj.33
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 05:02:56 -0700 (PDT)
In-Reply-To: <1411729595.1776139.172032293.6FCC3EBB@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-26 at 13:06 +0200, Hannes Frederic Sowa wrote:

> I thought that prefetchw() would be the canonical way to solve write
> stalls in CPUs and prepare the specific cache line to be written to.
> Interesting, thanks Eric.

True, and I have a tcp_ack() (tcp_clean_rtx_queue() more exactly) patch
that indeed uses prefetchw() to bring tcp_shinfo() in cache before the 
tcp_unlink_write_queue(skb, sk);

Performance went from 570000 packets per second to 820000 packets per
second on a TSO=off GSO=off workload.

But this applies after the https://patchwork.ozlabs.org/patch/392877/
patch (tcp: change tcp_skb_pcount() location )
