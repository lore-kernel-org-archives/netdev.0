From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: in-driver QoS
Date: Mon, 7 Jun 2004 23:35:04 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406072335.04125.vkondra@mail.ru>
References: <200406062128.47070.vkondra@mail.ru> <20040607140011.GC28639@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20040607140011.GC28639@wotan.suse.de>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

How could I use these multiple qdiscs? If I use existing driver framework, I 
have hard_start_xmit, that represent single queue. Do you have any examples 
how driver can access qdiscs directly? I.e. I have 4 queues in the driver, I 
want to fill it separately, start/stop incoming queues from stack etc.

Note also, we are talking about 100Mbps above MAC, which translates to about 
150 Mbps, within next 2 years. 100Mbps above MAC is criteria for TGn working 
group in IEEE (high throughput).

Vladimir.

On Monday 07 June 2004 17:00, Andi Kleen wrote:
> > Any ideas how to modify stack to support multiple Tx queues?
>
> It already has that kind of in the form of arbitary qdiscs. The trick
> will be only to do all queueing in the qdisc and keep the hardware
> queue length as small as possible. I think today's drivers can
> do that already by just plugging the queue most of the time,
> unless they really want a packet.
>
> Disadvantage will be more use of CPU time to refill driver
> queues, but at the relatively slow WLAN speeds that shouldn't
> be a big issue.
>
> BTW the standard qdisc pfifo_fast already has three queues,
> selected by the old TOS.  That may even be good enough for you
> already. Users can fine tune it by using firewall rules
> that change the TOS for specific protocols etc.
>
> -Andi
