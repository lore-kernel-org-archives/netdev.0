From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 2/3] net: TCP thin linear timeouts
Date: Wed, 28 Oct 2009 16:31:32 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0910281618330.19761@wel-95.cs.helsinki.fi>
References: <4AE72079.4030504@simula.no> <4AE7262B.1060703@gmail.com> <4AE83FE4.1050309@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-2146794911-1256740292=:19761"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andreas Petlund <apetlund@simula.no>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>
To: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754089AbZJ1Ob3@vger.kernel.org>
In-Reply-To: <4AE83FE4.1050309@nets.rwth-aachen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-2146794911-1256740292=:19761
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 28 Oct 2009, Arnd Hannemann wrote:

> Eric Dumazet schrieb:
> > Andreas Petlund a écrit :
> >> This patch will make TCP use only linear timeouts if the stream is 
> >> thin. This will help to avoid the very high latencies that thin 
> >> stream suffer because of exponential backoff. This mechanism is only 
> >> active if enabled by iocontrol or syscontrol and the stream is 
> >> identified as thin. 

...I don't see how high latency is in any connection to stream being 
"thin" or not btw. If all ACKs are lost it usually requires silence for 
the full RTT, which affects a stream regardless of its size. ...If not all 
ACKs are lost, then the dupACK approach in the other patch should cover 
it already.

> However, addressing the proposal:
> I wonder how one can seriously suggest to just skip congestion response 
> during timeout-based loss recovery? I believe that in a heavily 
> congested scenarios, this would lead to a goodput disaster... Not to 
> mention that in a heavily congested scenario, suddenly every flow will 
> become "thin", so this will even amplify the problems. Or did I miss 
> something?

Good point. I suppose such an under-provisioned network can certainly be
there. I have heard that at least some people who remove exponential back 
off apply it later on nth retransmission as very often there really isn't 
such a super heavy congestion scenario but something completely unrelated 
to congestion which causes the RTO.

-- 
 i.
--8323329-2146794911-1256740292=:19761--
