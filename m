From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: net-AIO and real-time TCP (blue sky research)
Date: Wed, 11 Aug 2004 23:06:16 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0408112305070.15405@localhost.localdomain>
References: <20040801235102.K1276@almesberger.net> <20040810155148.GA4630@in.ibm.com>
 <20040811201829.T28020@almesberger.net> <Pine.LNX.4.58.0408111643460.3103@localhost.localdomain>
 <20040811214044.U28020@almesberger.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Suparna Bhattacharya <suparna@in.ibm.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Werner Almesberger <werner@almesberger.net>
In-Reply-To: <20040811214044.U28020@almesberger.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 11 Aug 2004, Werner Almesberger wrote:

> Sridhar Samudrala wrote:
> > Your AIO-TCP looks pretty similar to the partial reliablity extension to
> > SCTP that allows an SCTP endpoint to signal to its peer that it is no longer
> > going to retransmit certain messages and should skip past those messages.
>
> Damn, so it's not such a crazy idea after all :-)
>
> Something like this would be useful for the sender side, if the
> receiver can't figure out on its own that it shouldn't wait for
> the data to arrive. (And, assuming that the sender skips data by
> leaving a gap, not by filling it with other data, which seems
> like a reasonable assumption if we use AIO-TCP at both ends. If
> the receiver may use regular TCP, the sender would have to try
> to fill the missing part, which can be hairy, particularly if
> some of the data-to-be-dropped has already be sent.)
>
> Clearly, any such thing on the sender side would need to have some
> means to detect that the receiver can recover from segments that
> are never sent.
>
> Is a concrete API for this functionality described somewhere ?
> (I only skimmed through the RFC, but the API mentioned there
> looks more like an abstract one.)

There is a sockets API extensions for SCTP draft that describes a
way for an app to specify timetolive value for a message.
This can be done using the standard sendmsg() with a control
mesage of type SCTP_SNDRCV.

Also a new API sctp_sendmsg() can be used which has timetolive
as an argument.

http://www.ietf.org/internet-drafts/draft-ietf-tsvwg-sctpsocket-08.txt

-Sridhar

>
> I like the term "partial reliability" :)
>
> Thanks,
> - Werner
>
> --
>   _________________________________________________________________________
>  / Werner Almesberger, Buenos Aires, Argentina     werner@almesberger.net /
> /_http://www.almesberger.net/____________________________________________/
>
