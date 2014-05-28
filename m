From: Chris Friesen <chris.friesen-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH/RFC] Re: recvmmsg() timeout behavior strangeness [RESEND]
Date: Wed, 28 May 2014 15:33:51 -0600
Message-ID: <5386563F.8000901@windriver.com>
References: <537E0961.8040005@gmail.com> <20140526134647.GB8176@kernel.org> <20140526211706.GA25474@kernel.org> <5384BEC5.2080607@gmail.com> <20140527192115.GD25474@kernel.org> <CAKgNAkht1vubHueYPpkRu_W5B8OYW3rPUkHeLEq5WMVbCvO47w@mail.gmail.com> <20140527203010.GA2764@kernel.org> <5385D47A.3070401@gmail.com> <20140528150720.GB2764@kernel.org> <063D6719AE5E284EB5DD2968C1650D6D1724F2A0@AcuExch.aculab.com> <20140528195004.GD2764@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	=?ISO-8859-1?Q?Ondrej_B=EDlka?= <neleai-9Vj9tDbzfuSlVyrhU4qvOw@public.gmane.org>,
	Caitlin Bestler <caitlin.bestler-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Elie De Brauwer <eliedebrauwer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Steven Whitehouse <steve-TMeXKDtMCpxBDgjK7y7TUQ@public.gmane.org>,
	=?ISO-8859-1?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>, Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>
To: "'Arnaldo Carvalho de Melo'" <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140528195004.GD2764-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/28/2014 01:50 PM, 'Arnaldo Carvalho de Melo' wrote:

> What is being discussed here is how to return the EFAULT that may happen
> _after_ datagram processing, be it interrupted by an EFAULT, signal, or
> plain returning all that was requested, with no errors.
>
> This EFAULT _after_ datagram processing may happen when updating the
> remaining timeout, because then how can userspace both receive the
> number of successfully copied datagrams (in any of the cases mentioned
> in the previous paragraph) and know that that timeout can't be used
> because there was a problem while trying to copy it to userspace
> (EFAULT)?


How does select() handle this problem?  It updates the timeout and also 
modifies other data.

Could we just check whether the timeout pointer is valid before doing 
anything else?  Of course we could still fault the page out while 
waiting for messages and then fail to fault it back in later, but that 
seems like a not-very-likely scenario.

Chris
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
