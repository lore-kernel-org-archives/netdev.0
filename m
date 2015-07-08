From: Erik Kline <ek@google.com>
Subject: Re: [PATCH net-next v2] ipv6: sysctl to restrict candidate source addresses
Date: Wed, 8 Jul 2015 21:41:58 +0900
Message-ID: <CAAedzxqvEx+dMCmM5YLbnmd9REpcWFi=+nZ4s0EaBe8mxSKKgQ@mail.gmail.com>
References: <1436151944-21072-1-git-send-email-ek@google.com>
 <CAKD1Yr02efR=-PxKsR0nhpJyXJBSMmTvRctcJnoqqkfreUpAig@mail.gmail.com>
 <1436342988.2928.9.camel@stressinduktion.org> <CAKD1Yr1RMjQ=VD=V4Vr4gdUDa6_ZT62SEdKBSUP3PogQMRYyUA@mail.gmail.com>
 <1436345014.3846.11.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lorenzo Colitti <lorenzo@google.com>,
	=?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:36374 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932348AbbGHMmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 08:42:20 -0400
Received: by wgxm20 with SMTP id m20so11410084wgx.3
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 05:42:18 -0700 (PDT)
In-Reply-To: <1436345014.3846.11.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I really would like to come up with a sane works-always behavior for
> this, but besides doing a retry on the complete source address selection
> algorithm I currently cannot come up with an idea.
>
> Maybe we can tweak saddr_eval a bit.

I think it all comes down to this: source address selection really
doesn't know anything about routing that could help it make a better
evaluation.

Reading the RFCs that seems to be by design, or at the very least
there is a kind of "implied flat-ish routing table" at work, which the
algorithm works around by having various "prefer same interface" type
of rules. So, after the routing lookup to determine outgoing interface
it's just looking at all the addresses on all the interfaces.  There
is no checking of any of the multiple possible routing tables, in part
because there just isn't all the right information available.

So, I figured the safe thing to do would be to not change existing
default behaviour but just introduce a knob to at least make it
possible to get the RFC recommended behaviour.

---

Re: not having a source address or returning a link-local source for a
global destination:  I think that's perfectly ok, if the knob is set.
Frequently the source address will just be tossed into a salad bowl of
(src, dst) pairs returned from DNS and 3484/6724 sorting will then
help pick a more globally optimum (src, dst) to work with.
