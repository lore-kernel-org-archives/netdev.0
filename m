From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: Fwd: in-driver QoS
Date: Mon, 7 Jun 2004 23:28:23 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406072328.23836.vkondra@mail.ru>
References: <200406072217.31924.vkondra@mail.ru> <40C4C42F.2040006@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
        James Ketrenos <jketreno@linux.jf.intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <40C4C42F.2040006@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff,

Point is, wireless will support QoS on link level. Ethernet have no QoS on 
link, thus one Tx queue was sufficient.

For those QoS discipline, parameters are chosen by access point. Network stack 
don't know these parameters. BTW, how could driver tell to the stack what QoS 
should be employed?

If stack do not provide exactly the same QoS as driver need, driver's one will 
not work.

For generic 802.11 wireless stack, it should be framework for the driver to 
use 4 Tx queues for diff serv (separate start/stop...), and also some hooks 
for integrated service. Otherwise, like with current, simple 802.11 w/o TGe 
and other extensions, each driver will need to reinvent the wheel.

I know very little about ATM, but it have QoS, both diff serv and int serv. 
May be it is worth to borrow from it?

Vladimir.

On Monday 07 June 2004 22:38, Jeff Garzik wrote:
> Vladimir Kondratiev wrote:
> > skb->priority help determining Tx queue, but fundamental problem is with
> > single Tx queue from network stack. Any smart queuing/scheduling etc.
> > made by driver, will render useless while network stack provides single
> > Tx queue.
>
> The packet schedulers already have multiple queues, why isn't the packet
> scheduling framework sufficient?
>
> Who cares if there is a single TX "delivery point" to the driver, as
> long as the driver knows how to differentiate queues.
>
> 	Jeff
