From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 1/1 V4] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Fri, 26 Sep 2014 11:06:37 -0700
Message-ID: <1411754797.16953.134.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140924160932.9721.56450.stgit@localhost>
	 <20140924161047.9721.43080.stgit@localhost>
	 <1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140924195831.6fb91051@redhat.com>
	 <CA+mtBx8s63TDe1XS7TzfscwhiRCgyeLkKLz2p-4et1erX0-dUQ@mail.gmail.com>
	 <1411586550.15395.46.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411611140.16953.1.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx-3HTHvodGXJ_zHArbeLtbeTc3XUc_CZr4CgfvU9BiDAA@mail.gmail.com>
	 <CAA93jw7Y5-5qwTcoqzRAv-DeRmVUA=hTX6b74hQPM=VmpNWQZA@mail.gmail.com>
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
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:34960 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755231AbaIZSGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 14:06:39 -0400
Received: by mail-pd0-f179.google.com with SMTP id ft15so13354755pdb.38
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 11:06:38 -0700 (PDT)
In-Reply-To: <CAA93jw7Y5-5qwTcoqzRAv-DeRmVUA=hTX6b74hQPM=VmpNWQZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-24 at 19:58 -0700, Dave Taht wrote:

> I have long hoped that the actual BQL limit in play would feed into
> TCP small queues when there are a lot of flows to make each tcp
> "small" queue gradually smaller...

Yep, but what do you do if you have 64 TX queues, each one having
different BQL limits ? This looks like a NP problem when you also have
millions of tcp flows.

Basically BQL limit is more a sign of local host being able to drain TX
completions fast or not.

Here at Google, we have a very tiny queue of at most 2 packets per flow,
and srtt being in usec units gives us a very dynamic signal, based on
end to end measures.

I am experimenting moving TSQ processing from tasklet to workqueue,
because we need faster response to {soft}irq when we so often enter
TCP stack.
