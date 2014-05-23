From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH/RFC] Re: recvmmsg() timeout behavior strangeness
 [RESEND]
Date: Fri, 23 May 2014 15:00:55 -0400 (EDT)
Message-ID: <20140523.150055.2214666905697701415.davem@davemloft.net>
References: <CAKgNAkgA_xTfRZhpyVwuACpCY7xMK89e0bK4PuVMG9reNV6Skw@mail.gmail.com>
	<20140512143451.GB13801@kernel.org>
	<20140521210535.GA5414@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	neleai-9Vj9tDbzfuSlVyrhU4qvOw@public.gmane.org, caitlin.bestler-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	eliedebrauwer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, steve-TMeXKDtMCpxBDgjK7y7TUQ@public.gmane.org,
	remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org, paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org,
	chris.friesen-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org
To: acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140521210535.GA5414-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Wed, 21 May 2014 18:05:35 -0300

> But after thinking a bit more, looks like we need to do that, please
> take a look at the attached patch to see if it addresses the problem.
> 
> Mostly it adds a new timeop to the per protocol recvmsg()
> implementations, that, if not NULL, should be used instead of
> SO_RCVTIMEO.
> 
> since the underlying recvmsg implementations already check that timeout,
> return what is remaining, that will then be used in subsequent recvmsg
> calls, at the end we just convert it back to timespec format.
> 
> In most cases it is just passed to skb_recv_datagram, that will check
> the pointer, use it and update if not NULL.
> 
> Should have no problems, but I only did a boot with a system with this
> patch applied, no problems noticed on a normal desktop session, ssh,
> etc.

This looks fine to me, but I have a small request:

+	return noblock ? 0 : timeop ? *timeop : sk->sk_rcvtimeo;

I keep forgetting which way these expressions associate, so if you could
parenthesize the innermost ?: I'd appreciate it. :)

Thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
