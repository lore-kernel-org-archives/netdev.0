From: vadim4j@gmail.com
Subject: Re: [PATCH iproute2] ip link: Show devices by link type
Date: Wed, 3 Dec 2014 03:13:05 +0200
Message-ID: <20141203011305.GA5945@angus-think.lan>
References: <1417370335-15772-1-git-send-email-vadim4j@gmail.com>
 <547E5F90.2060105@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35634 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbaLCBWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 20:22:47 -0500
Received: by mail-wi0-f169.google.com with SMTP id r20so31458130wiv.4
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 17:22:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <547E5F90.2060105@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 02, 2014 at 04:55:44PM -0800, Roopa Prabhu wrote:
> >  	int master;
> >+	char *link_kind;
> The name can be just "kind", given all the others dont use the link prefix
> >  } filter;
OK

> >+	if (filter.link_kind && tb[IFLA_LINKINFO]) {
> >+		char *link_kind = parse_link_kind(tb[IFLA_LINKINFO]);
> >+		if (strcmp(link_kind, filter.link_kind)) {
> >+			return -1;
> >+		}
> you can skip the braces
> >+	} else if (filter.link_kind)
> 
> you have if (filter.link_kind) twice, you can use a single if without the
> else.
> >+		return -1;
> >+
I need to skip interfaces which has not IFLA_LINKINFO attribute,
w/o "else if(...)" I get bridges with normal ether devices:
    
    bash# ip link show type bridge

    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default 
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    2: enp0s25: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN mode DEFAULT group default qlen 1000
        link/ether XX:XX:XX:XX:XX:XX brd ff:ff:ff:ff:ff:ff
    5: br0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default 
        link/ether 6e:02:f9:17:7f:10 brd ff:ff:ff:ff:ff:ff

but expected result should be only bridges.

Regards,
Vadim
