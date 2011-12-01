From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] netconsole: implement ipv4 tos support
Date: Thu, 1 Dec 2011 01:25:30 -0800
Message-ID: <CAHo-OowBEUmsprEvoZauxBSq8gGWFmZxNieF6kLN6tLPHCTN=A@mail.gmail.com>
References: <1322702330-31325-1-git-send-email-zenczykowski@gmail.com>
	<20111130173435.5e63afda@nehalam.linuxnetplumber.net>
	<CANP3RGfwUr3ho3Tz_cfVz4CBJWMktOb7MDbUYYXz7XfjErw7Zg@mail.gmail.com>
	<20111130182753.02798425@nehalam.linuxnetplumber.net>
	<CAHo-OoyQWk5xB7LcdCa+hLWvsiG-eY+Catdsa9zXG+01q3Y+3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:33404 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226Ab1LAJZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 04:25:31 -0500
Received: by yenl6 with SMTP id l6so1469627yen.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 01:25:30 -0800 (PST)
In-Reply-To: <CAHo-OoyQWk5xB7LcdCa+hLWvsiG-eY+Catdsa9zXG+01q3Y+3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Although interpretation of TOS is per organization, in practice the
>> values are standardized in places like RFC4594. For example, routing protocols
>> all use IPTOS_PREC_INTERNETCONTROL = 0xc0

One more thing should probably be mentioned here.
TOS interpretation is directly influenced by low level hardware
aspects of an organization's network.
Things like the number of hw priority queues and their scheduling/drop
types supported by all hosts, switches and routers across the TOS
domain.  What sort of prioritization can be done, how to map these
levels onto older hardware which supports only a subset of features
(or a smaller number of queues).  Etc.

Furthermore as we well know TOS isn't just a linear priority, from
lowest to highest.  There are very different aspects one may desire.
Latency (web pages), Jitter (voip), Packet loss (kernel crash dumps),
Monetary cost (data copies), Bandwith (video), Failure domains (ie.
presence of single points of failure), Seperation of loss-tolerant
from loss-intolerant traffic, etc, are all still very much desirable
in certain circumstances.

Furthermore it may be desirable to have tos have many unusual
behaviours - for example tos priority increase post traversal of
expensive links (for example cross-oceanic links) - since it would be
a pity to drop traffic close to its destination in favour of traffic
which is still close to its source.

Different people/orgs are bound to care about different aspects (axes).

Anyway... enough beating a dead horse.

- Maciej
