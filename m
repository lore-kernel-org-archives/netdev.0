From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] iplink_geneve: add UDP destination port configuration at
 link creation
Date: Fri, 18 Sep 2015 09:15:56 -0700
Message-ID: <CAEP_g=8vCm48Hgjnm2ZYTNc1K4QCN=Jvd6hfSRA5b3YEw1cA0w@mail.gmail.com>
References: <1442518065-23294-1-git-send-email-linville@tuxdriver.com>
 <1442522989.7946.4.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150918142618.GA18191@tuxdriver.com> <1442587524.7946.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:32803 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753152AbbIRQQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 12:16:17 -0400
Received: by lamp12 with SMTP id p12so32840077lam.0
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 09:16:15 -0700 (PDT)
In-Reply-To: <1442587524.7946.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 18, 2015 at 7:45 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2015-09-18 at 10:26 -0400, John W. Linville wrote:
>> On Thu, Sep 17, 2015 at 01:49:49PM -0700, Eric Dumazet wrote:
>> > On Thu, 2015-09-17 at 15:27 -0400, John W. Linville wrote:
>> > > Signed-off-by: John W. Linville <linville@tuxdriver.com>
>> > > ---
>> >
>> > >  }
>> > >
>> > > @@ -150,6 +159,10 @@ static void geneve_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
>> > >           else
>> > >                   fprintf(f, "tos %#x ", tos);
>> > >   }
>> > > +
>> > > + if (tb[IFLA_GENEVE_PORT])
>> > > +         fprintf(f, "dstport %u ",
>> > > +                 ntohs(rta_getattr_u16(tb[IFLA_GENEVE_PORT])));
>> >
>> > This looks strange.
>> >
>> > Kernel does :
>> >
>> > if (nla_put_u16(skb, IFLA_GENEVE_PORT, ntohs(geneve->dst_port)))
>> >         goto nla_put_failure;
>>
>> Indeed, you are right.  I had essentially copied some vxlan code when
>> I did my version of adding the port attribute, and didn't take much
>> care when adapting that code for the version that actually got merged.
>>
>> The current geneve code is using host byte-order for the UDP port in
>> the netlink messages.  But, I see that vxlan, gre, iptnl, etc are using
>> network byte order for specifying UDP ports in their netlink stuff.
>> Should geneve follow that practice as well?  Or does it matter?
>
> It might be too late to change the ABI, as geneve is in linux-4.2

We might be in luck actually. Geneve itself came earlier but I think
the ability to specify the dest port is in 4.3 only, so we still have
a chance to make it consistent.
