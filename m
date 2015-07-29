From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH 1/1] net/ipv4: Enable flow-based ECMP
Date: Wed, 29 Jul 2015 09:12:42 -0700
Message-ID: <CALx6S36NeeBeLj_UDMMm1-ub-cPy5n7OZhqGag2rN7bcQo9kWQ@mail.gmail.com>
References: <55B6E8AC.4060600@alliedtelesis.co.nz>
	<CALx6S361R1UeEECQn9vFDCS-wi_StoV6mekqgSK-0t-0NPvWEA@mail.gmail.com>
	<55B7F202.5050503@alliedtelesis.co.nz>
	<20150729061148.GB18456@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Richard Laing <Richard.Laing@alliedtelesis.co.nz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jmorris@namei.org" <jmorris@namei.org>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:35635 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbbG2QMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 12:12:43 -0400
Received: by igr7 with SMTP id 7so149403903igr.0
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 09:12:42 -0700 (PDT)
In-Reply-To: <20150729061148.GB18456@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 28, 2015 at 11:11 PM, Michal Kubecek <mkubecek@suse.cz> wrote:
> On Tue, Jul 28, 2015 at 09:20:02PM +0000, Richard Laing wrote:
>> >> diff --git a/include/net/flow.h b/include/net/flow.h
>> >> index 8109a15..d1d933d 100644
>> >> --- a/include/net/flow.h
>> >> +++ b/include/net/flow.h
>> >> @@ -79,6 +79,10 @@ struct flowi4 {
>> >>    #define fl4_ipsec_spi        uli.spi
>> >>    #define fl4_mh_type        uli.mht.type
>> >>    #define fl4_gre_key        uli.gre_key
>> >> +
>> >> +#ifdef CONFIG_IP_FLOW_BASED_MULTIPATH
>> > Why bother making this a CONFIG, round robin is a miserable algorithm
>> > anyway and nearly all the other packet steering mechanisms already use
>> > a hash.
>>
>> Fair enough, I will look at making it a sysctl option. I guess the
>> default can be the current behaviour.
>
> Hm... that's an interesting question. In general, it's better to use
> current behaviour as a default so that people are not surprised on
> upgrade. On the other hand, it used to be per-flow  - or rather per
> destination - earlier (until the routing cache removal, I believe) and
> per-flow distribution is IMHO preferrable in majority of use cases. In
> theory, there was a route attribute "equalize" to switch to per-packet
> distribution, but it was never actually implemented, AFAIK (it was
> recognized by ip and passed to kernel but ignored there).
>
> Anyway, config option is definitely inconvenient as most users install
> distribution kernels and do not configure their kernels themselves. Even
> boot parameter would be better - but sysctl sounds much better. Having
> both sysctl and per-route attribute would be perfect, of course.
>
IPv6 routing already uses a hash without any capability of setting
this to be round robin, probably every network device on the planet
performs ECMP using a hash since it is stateless algorithm, and as I
pointed most of our other packet steering mechanisms use a hash. So
the IPv4 path seems to be the odd man out here. Keeping round robin
seems around awfully conservative to me, and implies that we need to
implement it in IPv6 to maintain feature parity.

Tom

>                                                         Michal Kubecek
>
