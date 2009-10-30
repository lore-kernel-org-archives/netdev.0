From: apetlund@simula.no
Subject: Re: [PATCH 3/3] net: TCP thin dupack
Date: Fri, 30 Oct 2009 15:11:00 +0100
Message-ID: <644ddf8802a85c425aaf86c191161fa4.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Andreas Petlund" <apetlund@simula.no>,
	"Netdev" <netdev@vger.kernel.org>,
	"LKML" <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	"David Miller" <davem@davemloft.net>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932206AbZJ3OK6@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Thu, 29 Oct 2009, apetlund@simula.no wrote:
>
>> I apologise that some of you received this mail more than once. My
email
>> client played a HTML-trick on me.
>> >> +	/* If a thin stream is detected, retransmit after first
>> >> +	 * received dupack */
>> >> +	if ((tp->thin_dupack || sysctl_tcp_force_thin_dupack) &&
>> >> +	    tcp_dupack_heurestics(tp) > 1 && tcp_stream_is_thin(tp))
+		return 1;
>> >> +
>> >>  	return 0;
>> >>  }
>> >
>> > Have you tested it? ...I doubt this will work like you say and
>> retransmit
>> > something when the window is small. ...Besides, you should have built
>> this
>> > patch on top of the function rename you submitted earlier as after
>> DaveM
>> applied that this will no longer even compile...
>> >
>> > --
>> >  i.
>> >
>> We have performed extensive tests mapping the effect of the patch you
commented on some months ago. Since then, the only change was the one
you
>> requested of switching tcp_fackets_out() with tcp_dupack_heurestics().
After inspecting the code, I believed the effect should be equal to the
previous, only making considerations for SACK and FACK availability.
Please tell if this will break the intended effect, and I will modify
the
>> patch accordingly.
>
> Ah, you're of course right. FACK retransmits the head always but RFC3517
mode doesn't. I think you'd need to artificially lower (ie., to
calculate)
> the dupthresh (from tp->reordering) to be 1 for it to work as intented.
>
>> Graphs from our tests of the original patch can be found at the
location
>> linked to below.  I have tested the new one for functionality, but have
not et performed tests on this scope as the changes were minor. I will,
of
>> course, fix the function rename in the next iteration. Sorry for that.
http://folk.uio.no/apetlund/lktmp/
>
> You curiousity, have you run this more aggressive form of early
retransmit
> against the one ID gives? ...I checked your results but if I understood
them correctly the IDish early retransmit wasn't among the variants
used.

We have not implemented EFR for Linux TCP. We have, however, performed
tests where we compare the Free BSD implementation on SCTP with SCTP using
our proposed exp. bo. and dupACK modifications.  I know that this is not
directly comparable, and link to this as a digression:

http://folk.uio.no/apetlund/lktmp/SCTP_thin_compare.pdf

If you are interested in our set of SCTP experiments, it is summarised in
the paper linked to below:

http://simula.no/research/networks/publications/Simula.ND.311/simula_pdf_file

Regards,
Andreas
