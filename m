From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: in-driver QoS
Date: Tue, 8 Jun 2004 08:41:14 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406080841.14579.vkondra@mail.ru>
References: <200406062128.47070.vkondra@mail.ru> <200406072335.04125.vkondra@mail.ru> <1086651524.1037.10.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, hadi@cyberus.ca
In-Reply-To: <1086651524.1037.10.camel@jzny.localdomain>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 08 June 2004 02:38, jamal wrote:
> On Mon, 2004-06-07 at 16:35, Vladimir Kondratiev wrote:
> > How could I use these multiple qdiscs? If I use existing driver
> > framework, I have hard_start_xmit, that represent single queue. Do you
> > have any examples how driver can access qdiscs directly? I.e. I have 4
> > queues in the driver, I want to fill it separately, start/stop incoming
> > queues from stack etc.
>
> Maybe you can explain a little more: Do these 4 queues translate to 4
Exactly
> DMA rings or channles on the NIC? Could you not use a tag like fwmark to
> select DMA to send to?
> Explain the packet path once it hits the driver.
Let's put aside integrated service. For diff serv,
NIC have 4 DMA queues. These 4 queues acts as 4 independent 802.11 channels 
with different backoff and contention window parameters. Actually, it is 
dictated by TGe, and should be common for wireless stack. Queue consumption 
depends on conditions on air and access point settings. Access point set 
these different parameters for queues, and may change it time to time.

I think it would be not good to rely on 'tc' to provide proper mix of packets. 
Meanwhile, it is what I use, but it is not proper solution.
>
> > Note also, we are talking about 100Mbps above MAC, which translates to
> > about 150 Mbps, within next 2 years. 100Mbps above MAC is criteria for
> > TGn working group in IEEE (high throughput).
>
> Are these wireless NICs? Whats the big deal about 150Mbps?
Nothing special, but Andi mentioned that ...
> Disadvantage will be more use of CPU time to refill driver
> queues, but at the relatively slow WLAN speeds that shouldn't 
> be a big issue.
... and I want to note that it is not very slow network.

Vladimir.
