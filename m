From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH v3 net-next] net: ipv6: Add a sysctl to make optimistic
 addresses useful candidates
Date: Thu, 23 Oct 2014 17:12:50 +0200
Message-ID: <54491AF2.3070400@6wind.com>
References: <1414058399-19695-1-git-send-email-ek@google.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ben@decadent.org.uk, lorenzo@google.com, hannes@stressinduktion.org
To: Erik Kline <ek@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:52648 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbaJWPMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 11:12:54 -0400
Received: by mail-wg0-f48.google.com with SMTP id k14so1368644wgh.7
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 08:12:52 -0700 (PDT)
In-Reply-To: <1414058399-19695-1-git-send-email-ek@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/10/2014 11:59, Erik Kline a =C3=A9crit :
> Add a sysctl that causes an interface's optimistic addresses
> to be considered equivalent to other non-deprecated addresses
> for source address selection purposes.  Preferred addresses
> will still take precedence over optimistic addresses, subject
> to other ranking in the source address selection algorithm.
>
> This is useful where different interfaces are connected to
> different networks from different ISPs (e.g., a cell network
> and a home wifi network).
>
> The current behaviour complies with RFC 3484/6724, and it
> makes sense if the host has only one interface, or has
> multiple interfaces on the same network (same or cooperating
> administrative domain(s), but not in the multiple distinct
> networks case.
>
> For example, if a mobile device has an IPv6 address on an LTE
> network and then connects to IPv6-enabled wifi, while the wifi
> IPv6 address is undergoing DAD, IPv6 connections will try use
> the wifi default route with the LTE IPv6 address, and will get
> stuck until they time out.
>
> Also, because optimistic nodes can receive frames, issue
> an RTM_NEWADDR as soon as DAD starts.  If DAD fails, a separate
> RTM_DELADDR is always sent.
>
> Also: add an entry in ip-sysctl.txt for optimistic_dad.
>
> Signed-off-by: Erik Kline <ek@google.com>
I agree with the principle of the patch. This option is useful.


Thank you,
Nicolas
