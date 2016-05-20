From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v9 net-next 4/7] openvswitch: add layer 3 flow/port
 support
Date: Fri, 20 May 2016 11:20:04 +0200
Message-ID: <20160520112004.4f0a54e7@griffin>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
	<1462347393-22354-5-git-send-email-simon.horman@netronome.com>
	<20160517163250.7ead555e@griffin>
	<20160520052858.GA15505@vergenet.net>
	<20160520100028.0065a2ef@griffin>
	<20160520081120.GA17561@vergenet.net>
	<20160520081611.GB17561@vergenet.net>
	<20160520103939.723f2a42@griffin>
	<20160520091202.GC17561@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Lorand Jakab <lojakab@cisco.com>,
	Thomas Morin <thomas.morin@orange.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58391 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755839AbcETJUI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 May 2016 05:20:08 -0400
In-Reply-To: <20160520091202.GC17561@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 May 2016 18:12:05 +0900, Simon Horman wrote:
> 1. push_eth adds an Ethernet header with all-zero addresses and
>    the Ethernet type as determined from skb->protocol which is in
>    turn determined by the tunnel header (we have discussed that
>    bit before).
> 
>    In principle it is pushed when needed. And this happens automatically
>    as controlled by user-space.
> 
>    It is possible to modify the Ethernet addresses using a custom rule.
>    (I need to exercise that more often.)
> 
> 2. For the GRE part of the scenario above it is important to know that with
>    the accompanying user-space patch set OvS user-space the user-space
>    representation of a vport (from now on simply vport) may be "layer3" or
>    not.
> 
>    This allows OvS user-space to determine if an Ethernet header should be
>    present or not on receive. And if it needs to be present or not on
>    transmit. This allows it to automatically use pop_eth and push_eth to
>    control the presence of an Ethernet header so its there when it needs to
>    be and not when it doesn't.
> 
>    So if a GRE vport is "layer3" then no Ethernet header should be
>    present on transmit, regardless of where the packet came from. And
>    conversely if the GRE vport is not "layer3" then an Ethernet header
>    should be present.

I think this works for me. Thanks a lot for answering my questions!

> 3. With regards to the mirroring part of your connection, I need to check
>    on that and possibly its broken. But my thinking is that a mirroring
>    vport would regarded in the same way as any other vport in this respect
>    and the presence of the "layer3" flag would control whether an Ethernet
>    header is present or not.
> 
>    It may be the case that its not possible to use a tunnel vport as a
>    mirroring vport. And as all other vports currently do not support
>    "layer3" then currently an Ethernet header would always be present
>    on output to a mirror.

We can just require a mirror port to be always L2 and output the L3
packets with zero Ethernet addresses. For mirroring, this should be
okay(?)

 Jiri
