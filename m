From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: Intel and TOE in the news
Date: Tue, 22 Feb 2005 12:51:40 -0800
Message-ID: <200502222052.j1MKqaDD022407@guinness.s2io.com>
References: <20050222180711.GA84438@muc.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Leonid Grossman'" <leonid.grossman@neterion.com>, <hadi@cyberus.ca>,
        "'rick jones'" <rick.jones2@hp.com>, <netdev@oss.sgi.com>,
        "'Alex Aizman'" <alex@neterion.com>
To: "'Andi Kleen'" <ak@muc.de>, "'Stephen Hemminger'" <shemminger@osdl.org>
In-Reply-To: <20050222180711.GA84438@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




> -----Original Message-----
> From: Andi Kleen [mailto:ak@muc.de] 
> Sent: Tuesday, February 22, 2005 10:07 AM
> To: Stephen Hemminger
> Cc: Leonid Grossman; hadi@cyberus.ca; 'rick jones'; 
> netdev@oss.sgi.com; 'Alex Aizman'
> Subject: Re: Intel and TOE in the news
> 
> > Be careful, this may have the same problems that original 
> TSO code did.
> > Make sure and force the PUSH flag on these jumbo receives 
> or the TCP 
> > "every other segment" ACK logic will be busted.  There are 
> other parts of TCP
> > that depend on packet count as well and this inverse TSO 
> logic will break them.


TSO case is probably different - TSO hardware just sets PSH on the last
fragment only (and only if the flag was set on the original large tx
packet). Receiver doesn't really know if the sender is TSO-capable or not
and will ACK the same way - will it not?
Anyway, with LRO we do change rx packet count so affecting parts of TCP that
depend on packet count is indeed a concern; I guess we'll find out soon
enough whether there are real issues with the approach :-)

Leonid

> 
> Linux TCP RX path didn't care about PSH last time I checked. 
> It should make no difference how PSH is set on RX or if it is 
> set at all. At least unless Leonid wants to run his driver on 
> Darwin too, but that would be someone else's problem.
> 
> -Andi
> 
