From: Tom Herbert <therbert@google.com>
Subject: Re: ip6tables filter breakage.
Date: Wed, 6 Aug 2014 18:13:17 -0700
Message-ID: <CA+mtBx91JyKzMwTVsc-xuKj1jFxi1mdiWZCRHUHTYVU3Uw-U1g@mail.gmail.com>
References: <20140806195222.GA10618@redhat.com>
	<20140806.131354.1888027200650409969.davem@davemloft.net>
	<20140806215638.GA31519@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, davej@redhat.com,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:37140 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754158AbaHGBNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 21:13:18 -0400
Received: by mail-ie0-f180.google.com with SMTP id at20so3718659iec.25
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 18:13:17 -0700 (PDT)
In-Reply-To: <20140806215638.GA31519@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for catch an fix!

On Wed, Aug 6, 2014 at 3:01 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Wed, Aug 06, 2014 at 01:13:54PM -0700, David Miller wrote:
>> From: Dave Jones <davej@redhat.com>
>> Date: Wed, 6 Aug 2014 15:52:22 -0400
>>
>> CC:'ing netfilter-devel, Dave please do this in the future for
>> netfilter reports, thanks.
>>
>> > After updating to Linus' current tree with todays net/ merge,
>> > I noticed that ip6tables doesn't work any more..
>> >
>> > # ip6tables -F
>> > ip6tables v1.4.19.1: can't initialize ip6tables table `filter': No
>> > chain/target/match by that name
>> > Perhaps ip6tables or your kernel needs to be upgraded
>> >
>> > My config has CONFIG_IP6_NF_FILTER=m
>> > I also note that ip6table_filter.ko doesn't get auto-loaded now.
>> > But even after modprobing it, I get the same message.
>> >
>> > Is there some additional option I now need to enable ?
>> >
>> >
>> > I was a little surprised by how CONFIG_NF_TABLES is mandatory
>> > for iptables to keep working, even if you don't have nft userspace.
>> > (The only relevant thing in the Kconfig was related to x_tables,
>> >  which I wasn't using).
>> >
>> > Perhaps either some select's, or additional help text ?
>
> Cc'ing Tom:
>
> cb1ce2e ipv6: Implement automatic flow label generation on transmit
> has allocated socket option 64 which is already reserved by ip6tables.
>
> I'm going to send a patch to fix this.
