From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net 0/2] lwtunnel: make it really work, for IPv4
Date: Thu, 24 Sep 2015 01:08:08 +0200
Message-ID: <20150923230808.GA12825@pox.localdomain>
References: <cover.1442936392.git.jbenc@redhat.com>
 <87zj0d92ba.fsf@x220.int.ebiederm.org>
 <20150923080957.GB29680@pox.localdomain>
 <87lhbx72j2.fsf@x220.int.ebiederm.org>
 <20150923162927.6d437a1f@griffin>
 <8761313ud5.fsf@x220.int.ebiederm.org>
 <20150923225456.74c5cd1d@griffin>
 <878u7w6dxh.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:36663 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755779AbbIWXIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 19:08:11 -0400
Received: by wicgb1 with SMTP id gb1so226736548wic.1
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 16:08:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <878u7w6dxh.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/23/15 at 04:09pm, Eric W. Biederman wrote:

[...]

> *Blink* You were targeting net.git with a feature enhancement????
> I will just ignore that.

The point of this series is to not expose the src and dst port Netlink
bits to user space in a released kernel because the ABI is not set in
stone yet. Hence targeting net.

If patch 1 is regarded unacceptable we should at least pull in patch 2
to not expose these bits until this has been worked out to leave the
option proposed here on the table.

> What I was observing is that in general the only tunneled packets that
> need an ingress metadata dst for a tunneled medium ethernet like medium
> are arp and ndisc packets.  In other cases if you aren't doing something
> exceptional like openvswitch the normal routing should be sufficient.
> 
> Which means a ndo_reply_dst method could remove the need in many cases
> for an ingress metadata dst to need to be allocated.

The tunnel RX metadata collected is used to associate packets matching
a particular tunnel id with the appropriate virtual networks by forwarding
them to a separate netns, separate VRF device or a separate bridge.

More sophisticated hypervisors may run multiple tunnel endpoints on
the same host using different host addresses and differentiate packets
based on the underlay destination IP as well.

> Regardless a netdevice operation that digs into the packet and figures
> out what is necessary for a reply seems like the clean way to make this
> work for both arp and neighbour discovery.

I'm not disagreeing entirely although I disagree that you can do the
NDO without looking at the original metadata dst. Even a full fib
lookup based on the requested IP in the ARP header is somewhat error
prone. I fully agree though that once we support additional types
besides IP tunneling then such an NDO might in fact make sense.
