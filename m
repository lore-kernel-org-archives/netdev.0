From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: RFC 3484 support
Date: Thu, 13 Nov 2003 15:26:20 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0311131517110.3196-100000@netcore.fi>
References: <200311131007.NAA23770@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ulrich Drepper <drepper@redhat.com>, <netdev@oss.sgi.com>,
        <yoshfuji@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200311131007.NAA23770@yakov.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 13 Nov 2003 kuznet@ms2.inr.ac.ru wrote:
> Do you really need this?
> 
> Right now the kernel is able to to determine a valid source address
> derived from some known destination address and nothing more. It is
> just connect().
> 
> I do not understand rfc3484, actually. Does it involve some policies made
> inside libc, which could contradict to policies used by kernel? If so,
> it is definitely unimplementable without surgery in the kernel.

I'm not sure what you refer by policies.  The policies of "matching label"
and "higher precedence" could include manually configured policies which
might subsequently be different in kernel and in libc (at least).

But, I think you what you're really asking is whether we need destination 
address selection at all, because we already have policy control in the 
kernel for source address.  The short answer is "yes", the longer answer 
is below.

The destination address selection as specified by RFC 3484 is pretty 
much necessary for the "proper" address selection.  Just having source 
address selection is not enough, because if we get multiple inputs as 
destination addresses, there has to be some way of selecting the best of 
them (combined with a best source address), as a trivial example:

DNS lookup gives you 2002::1 and 2001::1 addresses (6to4 and native).

The node has 2002:f00::1 address configured, but no "native" address.

Currently getaddrinfo picks the destination address in a round-robin 
fashion.  However, the best (s,d) -pair is (2002:f00::1, 2002::1), and you 
currently get that only one half of the time.

This is a very simplistic example, but there are actually real failure 
modes and problems if the destination address selection is missing.

HTH

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
