From: Eric Lemoine <Eric.Lemoine@ens-lyon.fr>
Subject: Re: udp weirdness
Date: Fri, 27 Sep 2002 17:57:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020927155710.GM343@hookipa>
References: <20020927120223.GH343@hookipa> <Pine.GSO.4.30.0209271048160.4401-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Lemoine <Eric.Lemoine@ens-lyon.fr>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.30.0209271048160.4401-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > I figured out that packets can be dropped in pfifo_fast_enqueue()
> > [the default qdisc's enqueue func], even though the driver/kernel
> > flow control has triggered.
> >
> > And sendto does not notify the user when packet gets dropped because
> > the output queue overflows (as indicated in sendto manpage).
> >
> > Why doesn't the kernel just put the process into sleep instead of
> > dropping packets?
> >
> 
> What trigger do you suggest to wake up the process again?

I was thinking of putting processes into sleep on per-device lists.
Once the net driver sees the NIC is ready to send again it wakes up all
processes sleeping on its list. [If the socket from which the packet
comes from is marked non-blocking the process is not put into sleep 
(obviously) and EAGAIN is returned.]

Throwing away packets when not absolutely necessary does not make sense
to me. Please correct me if i'm wrong.

> A better idea maybe to return something to the socket so it can
> manage things instead -- not sure what to return though that wouldnt
> break some standard;
> 
> cheers,
> jamal

-- 
Eric
