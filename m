From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Question: Now that we have IPv6, do we need TCP/UDP port numbers?
Date: Wed, 27 May 2015 22:58:05 -0700
Message-ID: <CAM_iQpVoWfgVGSqCAvEF00sp0zPtFpurOzy7aB7LptW1+HzaFQ@mail.gmail.com>
References: <CAG4ptLioQQaQS30NX5n0XfQ+wNaDs986bZR_3dO5wzVRhZTrhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Coroutines <coroutines@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG4ptLioQQaQS30NX5n0XfQ+wNaDs986bZR_3dO5wzVRhZTrhg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Cc'ing netdev for discussion)

On Mon, May 25, 2015 at 4:17 PM, Coroutines <coroutines@gmail.com> wrote:
> I have a potentially dumb question to ask, and I'm posting it here
> because out of everywhere on the web I thought I would find the most
> experts relating to TCP/UDP's design/handling and its history here.
>
> I've recently started educating myself about Tor, about how you can
> bind a service to a local address+port and then host a hidden service
> that others can connect to from an onion address like this:
>
> 32rfckwuorlf4dlv.onion
>
> Just to be clear: This address provides a single service, you do not
> specify a port to "request" a specific service.
>
> I was thinking was that when TCP/UDP were designed, internet port
> numbers were thought up because it wasn't practical/easy to just
> register/allocate and assign another IPv4 address.  Today those of us
> with awesome ISPs are advertised /64's for a network prefix and we can
> do whatever we want claiming an address within /64 the gateway router
> will pass traffic to/from.  (IPv6 Stateless Address Autoconfiguration
> without privacy extensions enabled is evil btw)
>
> My point is this - we have a LOT of room to create addresses as needed
> - single-service addresses.  I was wondering if there are any
> absolutely necessary reasons we need ports - or if there would be
> benefits/advantages to getting rid of them.  Would TCP/UDP be easier
> to process in-kernel if it were only addresses?  Would it eliminate
> any ambiguities between Linux/Windows/FreeBSD networking stacks?
> Would reclaiming 4 bytes from the TCP/UDP structs be worth it (32 bits
> isn't usually word-size anymore).  It would definitely make port scans
> impractical if you tried to scan the assumed /64 host range of an
> address.  It would also mean no more expecting to find a service at a
> specific port (which I consider bad because it makes hosts easier to
> identify in a scan).
>
> We're used to being able to go to port 80 (HTTP) and port 22 (SSH) at
> a single address and "knowing" that we're accessing the same machine.
> For typical setups this is true, but for servers running reverse
> proxies to pass traffic through to another host this is not so true.
> ((Imo)) it would be no different having a single, separate address for
> each service.
>
> Furthermore, most of domains we go to are single-service - like
> navigating to gmail.com in a web browser.
>
> I thought it would be cool to have one address responding to name
> queries so DNS servers become more like a port mapper in the current
> sense. Asking for smtp.domain.tld would tell you the only address that
> would accept SMTP/mail traffic. (example)
>
> Anyway, again I want to say I'm sorry if this is the wrong place to
> dream about the future (or talk about the past).  I am new to the list
> and I couldn't think of anywhere else I might find experts in this
> area so closely related to its history.  IPv6 adoption has been slow
> so even if TCP/UDP/SCTP were redesigned to eliminate port numbers I
> doubt the revised protocols would be adopted quicker.  I just want to
> know the history and the reason for internet ports, if not simply to
> multiplex traffic to a limited number of addresses.  Is it just a
> convenience or was it a necessity for IPv4?  I'm not going to reply to
> anyone who responds (as I believe I'm off-topic), but I will read
> everything offered to me to learn from.  I want to know what you all
> think, by asking what I consider to be an original question.
>
> (thanks for reading)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
