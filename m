From: "'Jeff' R. Steinhagen" <Jeff@steinhagen.ch>
Subject: Re: forcing a packet to go through hw net device
Date: Tue, 10 May 2005 08:21:12 +0200
Message-ID: <200505100821.12636.Jeff@steinhagen.ch>
References: <HGEFKOBCHAIJDIEJLAKDIECOCBAA.sumit@elitecore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7BIT
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-reply-to: <HGEFKOBCHAIJDIEJLAKDIECOCBAA.sumit@elitecore.com>
To: Sumit <sumit@elitecore.com>
Content-disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

Thanks. The binding to a specific device does not seem to solve the problem. 
The bypass seem to be behind the filter layer.

It know that it works if the packet is created on the device level itself, but 
I would like to ("cleanly") profile the whole closed loop including the 
_physical_ device:
application->socket1-> ...kernel...-> physical layer 
-> .. kernel..-> socket2 -> application
without bypassing e.g. the arp. 

Hoped to avoid modifying and temporarily removing the bypass from the kernel 
(-> ugly hack).



Cheers,
Jeff


On Tuesday 10 May 2005 08:02, you wrote:
> Check out netfilter ROUTE target.
> All the best,
> -- Sumit
>
> > -----Original Message-----
> > From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com]On
> > Behalf Of 'Jeff' R. Steinhagen
> >
> > Hi!
> >
> > I have a (maybe trivial) question about the kernel's networking code:
> >
> > A packet with an "outside" destination goes through all layers
> > including the
> > hardware interface (user->socket->protocol->IP->HW). However if
> > the packet is
> > addressed to a local IP the transport through and checks by the hardware
> > layer are avoided. This is perfectly OK for "normal" network usage.
> >
> > I am profiling some network hardware and related code. Is it
> > possible to force
> > an internally generated packet to be send through all/the hardware
> > layers?
