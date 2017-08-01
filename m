From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ss: Enclose IPv6 address in brackets
Date: Tue, 1 Aug 2017 07:41:45 -0700
Message-ID: <20170801074145.15e07dd1@xeon-e3>
References: <fc81757c-8dbb-dbed-7a24-7011cb8bb9e0@der-flo.net>
        <063D6719AE5E284EB5DD2968C1650D6DD00480ED@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: 'Florian Lehner' <dev@der-flo.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:38545 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751352AbdHAOlu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 10:41:50 -0400
Received: by mail-pg0-f41.google.com with SMTP id l64so8720204pge.5
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 07:41:50 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD00480ED@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Aug 2017 11:11:03 +0000
David Laight <David.Laight@ACULAB.COM> wrote:

> From: Florian Lehner
> > Sent: 29 July 2017 13:29
> > This patch adds support for RFC2732 IPv6 address format with brackets
> > for the tool ss. So output for ss changes from
> > 2a00:1450:400a:804::200e:443 to [2a00:1450:400a:804::200e]:443 for IPv6
> > addresses with attached port number.
> > 
> > Signed-off-by: Lehner Florian <dev@der-flo.net>
> > ---
> >  misc/ss.c | 6 +++++-
> >  1 file changed, 5 insertions(+), 1 deletion(-)
> > 
> > diff --git a/misc/ss.c b/misc/ss.c
> > index 12763c9..db39c93 100644
> > --- a/misc/ss.c
> > +++ b/misc/ss.c
> > @@ -1059,7 +1059,11 @@ static void inet_addr_print(const inet_prefix *a,
> > int port, unsigned int ifindex
> >  			ap = format_host(AF_INET, 4, a->data);
> >  		}
> >  	} else {
> > -		ap = format_host(a->family, 16, a->data);
> > +		if (a->family == AF_INET6) {
> > +			sprintf(buf, "[%s]", format_host(a->family, 16, a->data));
> > +		} else {
> > +			ap = format_host(a->family, 16, a->data);
> > +		}
> >  		est_len = strlen(ap);  
> ...
> 
> There are some strange things going on with global variables if this works at all.
> The text form of the address is in buf[] in one path and *ap in the other.
> 
> One option might be to call format_host() then use strchr(ap, ':')
> to add [] if the string contains any ':'.
> 
> 	David
> 

That sounds like a better solution.

Also what about IN6ADDR_ANY
