From: Steven Whitehouse <steve-TMeXKDtMCpxBDgjK7y7TUQ@public.gmane.org>
Subject: Re: recvmmsg() timeout behavior strangeness
Date: Thu, 10 Jan 2013 10:04:09 +0000
Message-ID: <1357812249.2760.6.camel@menhir>
References: <CAHO5Pa2goUtiBU8ye2beTBExL4it2-aDCPBhDOGyO3NX_PV_pQ@mail.gmail.com>
	 <50EDF01E.10709@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>,
	Caitlin Bestler <caitlin.bestler-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Chris Van Hoof <vanhoof-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Clark Williams <williams-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andrew Grover <andy.grover-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Elie De Brauwer <eliedebrauwer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
To: Chris Friesen <chris.friesen-b7o/lNNmKxtBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <50EDF01E.10709-b7o/lNNmKxtBDgjK7y7TUQ@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, 2013-01-09 at 16:33 -0600, Chris Friesen wrote:
> On 12/23/2012 02:50 PM, Michael Kerrisk wrote:
> 
> > If I understand correctly, the *intended* purpose of the timeout
> > argument is to set a limit on how long to wait for additional
> > datagrams after the arrival of an initial datagram. However, the
> > syscall behaves in quite a different way. Instead, it potentially
> > blocks forever, regardless of the timeout.
> 
> Looking at the code, I think you're correct.
> 
> The comments for a2e2725 say the timeout works like for ppoll(), where 
> it is "an upper limit on the time for which poll() will block, in 
> milliseconds."
> 
> I wonder if we could play some games with sk->sk_rcvtimeo to accomplish 
> this?
> 
> Chris

Which timeout are we talking about? I've been copied into the thread
without seeing the start of it.

If this is the rcvtimeo then afaik this is supposed to be the max time
that the call waits for data, but is overridden by MSG_DONTWAIT, for
example, on a per call basis. I'd assume that recvmmsg should work
exactly like recvmsg in this case unless there is a good reason for it
to differ,

Steve.


--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
