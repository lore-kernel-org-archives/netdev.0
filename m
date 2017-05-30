From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net: ndisc.c: reduce size of
 __ndisc_fill_addr_option()
Date: Mon, 29 May 2017 21:24:21 -0700
Message-ID: <1496118261.2618.12.camel@perches.com>
References: <20170527151514.GA3347@avx2>
         <20170529.233109.702640863399503414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Linyu.Yuan@alcatel-sbell.com.cn, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0027.hostedemail.com ([216.40.44.27]:56276 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750708AbdE3EYY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 00:24:24 -0400
In-Reply-To: <20170529.233109.702640863399503414.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-05-29 at 23:31 -0400, David Miller wrote:
> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Sat, 27 May 2017 18:15:14 +0300
> 
> >> --- a/net/ipv6/ndisc.c
> >> +++ b/net/ipv6/ndisc.c
> >> @@ -148,17 +148,18 @@ void __ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
> > 
> >>      space -= data_len;
> >> -    if (space > 0)
> >> -            memset(opt, 0, space);
> >> +
> >> +    memset(opt, 0, space);
> > 
> > This can't be right.
> > 
> > And what size are you reducing?
> 
> It is right, space equals the same thing it would have equaled
> before his changes, and a memset() of zero length will do the
> right thing.
> 
> Finally, if space can be negative here, we have real problems.

__ndisc_fill_addr_option is exported so yeah.
