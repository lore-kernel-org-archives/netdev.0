From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] netpoll: fix netconsole IPv6 setup
Date: Thu, 6 Feb 2014 14:09:18 -0800
Message-ID: <CAHA+R7PrXGeQCM1ZnY2G5f02qm_EaTX__RFut7iFGUh3HBJ1GA@mail.gmail.com>
References: <1391708052-11188-1-git-send-email-sd@queasysnail.net>
	<CAHA+R7OQYZ5RLn3v0nucKB=CVpDCZqp=HyNL=qgC9bViVKEuAQ@mail.gmail.com>
	<20140206205850.GA12704@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:60156 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296AbaBFWJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 17:09:20 -0500
Received: by mail-lb0-f169.google.com with SMTP id q8so2040900lbi.28
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 14:09:18 -0800 (PST)
In-Reply-To: <20140206205850.GA12704@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 6, 2014 at 12:58 PM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> 2014-02-06, 12:34:10 -0800, Cong Wang wrote:
>> On Thu, Feb 6, 2014 at 9:34 AM, Sabrina Dubroca <sd@queasysnail.net> wrote:
>> >  net/core/netpoll.c | 4 +++-
>> >  1 file changed, 3 insertions(+), 1 deletion(-)
>> >
>> > diff --git a/net/core/netpoll.c b/net/core/netpoll.c
>> > index c03f3de..a664f78 100644
>> > --- a/net/core/netpoll.c
>> > +++ b/net/core/netpoll.c
>> > @@ -948,6 +948,7 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
>> >  {
>> >         char *cur=opt, *delim;
>> >         int ipv6;
>> > +       bool ipversion_set = false;
>> >
>>
>> Or initialize 'ipv6' to -1 and then check if it is -1?
>
> It's overwritten when we parse the remote address. And np->ipv6 is a
> bool, so we can't store it there either.
>


Yeah, I misunderstood the problem. Your fix looks good.

Acked-by: Cong Wang <cwang@twopensource.com>

For net-next, I think we should change bool np->ipv6 to int np->ip_version,
so that we can tell if it is set or not.

Thanks!
