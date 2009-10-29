From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 1/3] net: TCP thin-stream detection
Date: Thu, 29 Oct 2009 22:26:49 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0910292215420.14335@melkinkari.cs.Helsinki.FI>
References: <4AE72075.4070702@simula.no> <4AE7B5D6.8070001@gmail.com>
 <38EB8C31-A96A-4C5C-88D8-8F6BF0E9225F@simula.no> <4AE9C396.3040705@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andreas Petlund <apetlund@simula.no>,
	William Allen Simpson <william.allen.simpson@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Christian Samsel <Christian.Samsel@rwth-aachen.de>
To: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756652AbZJ2U0r@vger.kernel.org>
In-Reply-To: <4AE9C396.3040705@nets.rwth-aachen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 29 Oct 2009, Arnd Hannemann wrote:

> Andreas Petlund schrieb:
> > Den 28. okt. 2009 kl. 04.09 skrev William Allen Simpson:
> > 
> >> Andreas Petlund wrote:
> >>> +/* Determines whether this is a thin stream (which may suffer from
> >>> + * increased latency). Used to trigger latency-reducing mechanisms.
> >>> + */
> >>> +static inline unsigned int tcp_stream_is_thin(const struct  
> >>> tcp_sock *tp)
> >>> +{
> >>> +	return tp->packets_out < 4;
> >>> +}
> >>> +
> >> This bothers me a bit.  Having just looked at your Linux presentation,
> >> and not (yet) read your papers, it seems much of your justification  
> >> was
> >> with 1 packet per RTT.  Here, you seem to be concentrating on 4,  
> >> probably
> >> because many implementations quickly ramp up to 4.
> >>
> > 
> > The limit of 4 packets in flight is based on the fact that less than 4  
> > packets in flight makes fast retransmissions impossible, thus limiting  
> > the retransmit options to timeout-retransmissions. The criterion is  
> 
> There is Limited Transmit! So this is generally not true.
> 
> > therefore as conservative as possible while still serving its purpose.  
> > If further losses occur, the exponential backoff will increase latency  
> > further. The concept of using this limit is also discussed in the  
> > Internet draft for Early Retransmit by Allman et al.:
> > http://www.icir.org/mallman/papers/draft-ietf-tcpm-early-rexmt-01.txt
> 
> This ID is covering exactly the cases which Limited Transmit does not
> cover and works "automagically" without help of application. So why not
> just implement this ID?

I even gave some advise recently to one guy how to polish up the early 
retransmit implementation of his. ...However, I think we haven't heard 
from that since then... I added him as CC if he happens to have it already 
done.

It is actually so that patches 1+3 implement sort of an early retransmit, 
just slightly more aggressive of it than what is given in ID but I find 
the difference in the aggressiveness rather insignificant. ...Whereas the 
RTO stuff is more questionable.


-- 
 i.
