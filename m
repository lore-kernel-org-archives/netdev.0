From: Andrew McGregor <andrew@indranet.co.nz>
Subject: Re: RFC:  p&p ipsec without authentication
Date: Mon, 16 Dec 2002 10:59:10 +1300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3050000.1039989550@localhost.localdomain>
References: <Pine.LNX.4.50L.0212151745360.2711-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Rik van Riel <riel@conectiva.com.br>, netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.50L.0212151745360.2711-100000@imladris.surriel.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It's not crazy at all.  Perfectly practical, now that lots of people have 
fast enough machines and slow enough connections that it won't drive them 
mad with the performance issues :-)

Actually, it can be done (fairly) securely against MITM attacks as well. 
Check out a keying protocol called HIP, most of the resources are linked to 
from www.hip4inter.net.

The basic idea is that each end prove to the other that they know a private 
key.  The MITM protection is quite hard to describe :-)

And it can be done (at least on IPv6) with almost zero cost in time for 
connections that don't support HIP, as well as only one round trip + 
compute time for those that do.

There are four implementations in progress, two for linux.  It would be 
very nice to get the necessary hooks into the mainline kernel.

Cool, eh?

Andrew

--On Sunday, December 15, 2002 18:34:06 -0200 Rik van Riel 
<riel@conectiva.com.br> wrote:

> Hi,
>
> I've got a crazy idea.  I know it's not secure, but I think it'll
> add some security against certain attacks, while being non-effective
> against some others.
>
> The idea I have is letting the ipsec layer do opportunistic encryption
> even when there are no ipsec keys known for the destination address,
> ie. negotiate a key when none is in the configuration or DNS.
>
> I know this gives absolutely no protection against man-in-the-middle
> attacks (except maybe being able to detect them), but it should prevent
> passive sniffing of network traffic, as done by some governments.
>
> If this "random" encryption could be turned on with one argument to
> ip or ifconfig and millions of hosts would use it, sniffing internet
> traffic might just become impractical (or too expensive) for large
> organisations.   Furthermore, even if just 0.1% of the hosts were to
> use ipsec authentication, the 3-letter agencies would be faced with
> the additional challenge of identifying which connections could safely
> be intercepted with man-in-the-middle attacks and which couldn't.
>
> Not to mention the fact that the port number on many communications
> would be invisible, vastly increasing the difficulty of doing any
> kind of statistical analysis on the traffic that's traversing the
> network.
>
> Is this idea completely crazy or only slightly ?
>
> regards,
>
> Rik
> --
> Bravely reimplemented by the knights who say "NIH".
> http://www.surriel.com/		http://guru.conectiva.com/
> Current spamtrap:  <a
> href=mailto:"october@surriel.com">october@surriel.com</a> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
>
