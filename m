From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: IPv6 6to4 on site-local networks.
Date: Fri, 12 Sep 2003 21:00:20 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309122049220.27849-100000@netcore.fi>
References: <1063388303.7869.410.camel@imladris.demon.co.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1063388303.7869.410.camel@imladris.demon.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 12 Sep 2003, David Woodhouse wrote:
> On Fri, 2003-09-12 at 20:29 +0300, Pekka Savola wrote:
> > You have this wrong assumption that IPv6 is engineered with RFC1918 in
> > mind.  Site-locals were indeed that.  But the point of deprecating them
> > was to get *rid of* (at least to a degree) RFC1918 addresses in IPv6.
>
> But RFC1918 is what makes intranets work. 

.. in a broken manner.  We already have IPv4.  If you want to deploy IPv6, 
do it properly.  IPv6 is about global addressing.

The bottom line is: it's just so much better idea to use global addresses 
and filtering.

> And the proposal you pointed
> me at puts them _back_ again, just gratuitously globally unique, and
> without the semantics which actually made them _more_ useful than
> RFC1918; made them ideal for multi-homing with both site- and global-
> scope addresses.

Also, such semantics ("site-locals always preferred") caused a number of
problems.

> > Leakage is used to refer to a lot more than just source/destination 
> > addresses.  For example, addresses leak when you use a Peer-to-peer system 
> > behind a NAT; addresses leak when you contact to an FTP server from behind 
> > a NAT, etc.  Addresses leaking inside the application is a much more 
> > difficult problem.
> 
> Unlike IPv4 and RFC1918, I thought IPv6 and site-local addressing
> _solved_ this, by letting multi-homing work properly. Hosts _wouldn't_
> contact external machines using their site-scope address through a NAT;
> instead they'd have a global-scope address for that. Wasn't that the
> point?

There is a problem especially with multi-party applications, which do 
referrals.  Consider theree nodes A, B, and C.  A and B are in the same 
site and have both globals and site-locals.  C has only globals.  By the 
"site-local smallest scope rule", A and B talk using site-locals.  
However, if B tells C to contact A, he gives C a site-local address of A, 
instead of the global.  And C can't handle it.

If you're interested to go a bit deeper to the reasoning, you may be 
interested to read 
http://www.ietf.org/internet-drafts/draft-wasserman-ipv6-sl-impact-02.txt

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
