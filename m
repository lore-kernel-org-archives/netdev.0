From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: [PATCHv2 net] net: restore lro after device detached from bridge
Date: Tue, 03 Feb 2015 10:29:00 +0800
Message-ID: <54D0326C.2050704@gmail.com>
References: <1422621209-23222-1-git-send-email-fan.du@intel.com> <54CBEE24.8000603@redhat.com> <54CEDEDC.7060507@gmail.com> <20150202111556.GA8655@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	Fan Du <fan.du@intel.com>, bhutchings@solarflare.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:43092 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932160AbbBCCdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 21:33:16 -0500
Received: by mail-pa0-f53.google.com with SMTP id kx10so89827860pab.12
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2015 18:33:15 -0800 (PST)
In-Reply-To: <20150202111556.GA8655@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B402=E6=9C=8802=E6=97=A5 19:15, Michal Kubecek =E5=
=86=99=E9=81=93:
> On Mon, Feb 02, 2015 at 10:20:12AM +0800, Fan Du wrote:
>>
>> I think you are talking about bad scenarios when net device is
>> attached to a bridge.  Then what's the good reason user has to pay
>> extra cpu power for using GRO, instead of using hw capable LRO/RSC
>> when this net device is detached from bridge acting as a standalone
>> NIC?
>
> Being bridged is only one of the situations when LRO needs to be
> disabled. Does your patch make sure it doesn't enable LRO if there ar=
e
> other reasons for it to be disabled, e.g. if forwarding is enabled fo=
r
> it or any of its upper devices?
>
> I'm afraid the only way to make the automatic reenabling work correct=
ly
> would be to keep track if LRO was disabled manually (e.g. by ethtool)=
 or
> only automatically because the device is bridged, forwarding is enabl=
ed
> for it, LRO is disabled for any upper device etc. And to reenable LRO
> only in the second case and even then only if none of the possible
> reasons holds. I don't think it's worth the effort.
>
>> Note, SRC is defaulted to *ON* in practice for ALL ixgbe NICs, as sa=
me
>> other RSC capable NICs.
>
> A very bad idea, IMHO. A lot of bug reports resulted from it.

Why are you saying this an idea?? this a fact for all RSC capable NIC d=
rivers.
search drivers/net/ethernet/ to find more.

>> Attaching net device to a bridge _once_ should not changed its defau=
lt
>> configuration, moreover it's a subtle change without any message tha=
t
>> user won't noticed at all.
> IMHO the key point here is that LRO enabled when it shouldn't is much
> more serious problem than LRO disabled when it could be enabled.

I agree with you here more than I disagree.
btw, I see this subtle behaviour not because I "seeing issues with rout=
ing or
bridging being enabled and" as Alexander assuming, it's because I see m=
y testbed
82599EB supports LRO, and the driver enabled after probing from code re=
view,
but for no reason ethtool -k reports lro is off, it looks like this int=
erface
is bound to bridge by one of service.

>
>                                                         Michal Kubece=
k
>
