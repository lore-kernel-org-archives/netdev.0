From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute2] regression in ss output
Date: Mon, 16 Oct 2017 12:33:20 +0200
Message-ID: <20171016103320.GP11332@orbyte.nwl.cc>
References: <AM4PR0901MB125261BF480B49D2BA2DF46BCC480@AM4PR0901MB1252.eurprd09.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Humberto Alves <hjalves@live.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35078 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751901AbdJPKdY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 06:33:24 -0400
Content-Disposition: inline
In-Reply-To: <AM4PR0901MB125261BF480B49D2BA2DF46BCC480@AM4PR0901MB1252.eurprd09.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Oct 13, 2017 at 09:57:37AM +0000, Humberto Alves wrote:
> Hi! With the last iproute2 release, ss command output does not 
> differentiate between any-address IPv4 sockets from the IPv6 ones.
> I don't know if this is an expected behaviour, but the old output looks 
> more useful. Below I pasted the difference between the old behaviour and 
> the new one.

Although the change is certainly intentional (it was introduced by
Stephen Hemminger as a side effect of aba9c23a6e1cb ("ss: enclose IPv6
address in brackets"), I second reverting to the old display of
in6addr_any as '::'.

> I am happy to send a patch if you want. Thanks

It should be enough to just getting rid of the

| if (!memcmp(a->data, &in6addr_any, sizeof(in6addr_any))) {

case in inet_addr_print(). The else-case which calls format_host()
should deal with in6addr_any just fine. This way the address also gets
enclosed in brackets which helps separating it from the ':port' part.

Cheers, Phil
