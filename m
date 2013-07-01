From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 3/3] udp: make use of static_key_slow_set_true()
 interface
Date: Mon, 01 Jul 2013 10:28:02 -0400
Message-ID: <1372688882.22688.1.camel@gandalf.local.home>
References: <cover.1372457176.git.jbaron@akamai.com>
	  <7fe0eaba62a8529b387ddb3205713d8bb6156ec1.1372457176.git.jbaron@akamai.com>
	 <1372475620.18733.353.camel@gandalf.local.home>
	 <51D10390.4060905@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "andi@firstfloor.org" <andi@firstfloor.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mingo@kernel.org" <mingo@kernel.org>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Jason Baron <jbaron@akamai.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51D10390.4060905@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-07-01 at 00:20 -0400, Jason Baron wrote:
>   
> >> @@ -1450,7 +1449,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
> >>   		goto drop;
> >>   	nf_reset(skb);
> >>   
> >> -	if (static_key_false(&udp_encap_needed) && up->encap_type) {
> >> +	if (static_key_false(&udp_encap_needed.key) && up->encap_type) {
> > I wonder if we should add a static_bool_key_false(), because that added
> > ".key" is a bit confusing.
> >
> > -- Steve
> >
> 
> Yeah - that is sort of ugly, but it avoids introducing a new branch API 
> call. That said, a 'static_bool_key_false()' would probably be a simple 
> wrapper function.

My main concern was to keep true/false separate from counters to
document how this is being used. A simple wrapper would work too.

-- Steve
