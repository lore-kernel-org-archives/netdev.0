From: Eric Lemoine <Eric.Lemoine@ens-lyon.fr>
Subject: Re: udp weirdness
Date: Fri, 27 Sep 2002 17:19:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020927151908.GL343@hookipa>
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

On Fri, Sep 27, 2002 at 10:53:00AM -0400, jamal wrote:
>
> On Fri, 27 Sep 2002, Eric Lemoine wrote:
> 
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
> A better idea maybe to return something to the socket so it can
> manage things instead -- not sure what to return though that wouldnt
> break some standard;

Linux seems to be the only one to not return ENOBUFS in this overflow
case (from sendto manpage), so i suspect it should not break any
standard.

-- 
Eric
