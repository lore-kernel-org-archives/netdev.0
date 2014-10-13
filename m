From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Network optimality (was Re: [PATCH net-next] qdisc: validate
 skb without holding lock_
Date: Mon, 13 Oct 2014 22:27:17 +0200
Message-ID: <20141013222717.42f3c399@redhat.com>
References: <CAA93jw58cBPToe7oL6YH-178n2jg+qh5GYJW7Ww9NHgcb5QPnA@mail.gmail.com>
	<CAL4WiioOodM60_Ud6qyGt1_uyeqpDeGFF6PtEKtGa=NwHhVFiw@mail.gmail.com>
	<1413219532.9362.109.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAA93jw5MKVaNaObVD3Lm=DP0ie6HcjwOvt0X-whDLJD_6hF5bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Toke =?UTF-8?B?SMO4aWxhbmQtSsO4cmdlbnNlbg==?= <toke@toke.dk>,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>, brouer@redhat.com
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46764 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753340AbaJMU1n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2014 16:27:43 -0400
In-Reply-To: <CAA93jw5MKVaNaObVD3Lm=DP0ie6HcjwOvt0X-whDLJD_6hF5bw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 13 Oct 2014 10:20:17 -0700 Dave Taht <dave.taht@gmail.com> wrote:

> On Mon, Oct 13, 2014 at 9:58 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> >> On Oct 13, 2014 7:22 AM, "Dave Taht" <dave.taht@gmail.com> wrote:
[...]
> 
> I would like to also get better behavior out of gigE and below, and for
> these changes to not impact the downstream behavior of the network
> overall.

I also care about 1Gbit/s and below, that why I did some many tests
(with igb at 10Mbit/s, 100Mbit/s and 1Gbit/s).  

 
> To give you an example, I would like to see the tcp flows in the
> 2nd chart here, to converge faster than the 5 seconds they currently
> take at GigE speeds.
> 
> http://snapon.lab.bufferbloat.net/~cero2/nuc-to-puck/results.html

In the last graph, where you cannot saturate the link, because you
turned off GSO, GRO and TSO.  Here I expect you will see the benefit of
the qdisc bulking. That is, will be able to saturate the link and
achieve the lower latency as BQL will cut off the bursts at +1 MTU.
I would be interested in the results...


> > We made all these changes so that we can spend cpu cycles at the right
> > place.

Exactly. 

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
