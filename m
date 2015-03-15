From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] ss: better 32bit support
Date: Sat, 14 Mar 2015 18:51:31 -0700
Message-ID: <1426384291.11398.199.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426006607.11398.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1426360760.4173.101.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemming@brocade.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:34958 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636AbbCOBve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 21:51:34 -0400
Received: by igad1 with SMTP id d1so15388099iga.0
        for <netdev@vger.kernel.org>; Sat, 14 Mar 2015 18:51:33 -0700 (PDT)
In-Reply-To: <1426360760.4173.101.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-03-14 at 19:19 +0000, Ben Hutchings wrote:
> On Tue, 2015-03-10 at 09:56 -0700, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>


> > -static unsigned long cookie_sk_get(uint32_t *cookie)
> > +static unsigned long long cookie_sk_get(const uint32_t *cookie)
> >  {
> > -	return (((unsigned long)cookie[1] << 31) << 1) | cookie[0];
> > +	return (((unsigned long long)cookie[1] << 31) << 1) | cookie[0];
> 
> Then you should also use << 32 instead of splitting it into two shifts.

Yep, why not, although compiler does not care : no shift at all is
generated anyway.

Since kernel code no longer uses this << 31 trick, we can align ss code.
