From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC PATCH net-next 3/3] virtio-net: Add accelerated RFS support
Date: Fri, 17 Jan 2014 20:59:15 -0800
Message-ID: <CA+mtBx8eRuWpYkYoPbuCaO1h0Y+g96zJB96zP17ZixOwZ1_gmQ@mail.gmail.com>
References: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
	<1389795654-28381-4-git-send-email-zwu.kernel@gmail.com>
	<1389907887.11912.87.camel@bwh-desktop.uk.level5networks.com>
	<CAEH94LjHcxkXLvs6AMNop_yzKG0zaT2mAgsAb21i+RtMbkXbmQ@mail.gmail.com>
	<1389914188.11912.146.camel@bwh-desktop.uk.level5networks.com>
	<CAEH94LgKJ0qThGHS-hqXsYKqOe+ns2pRi-wfZy=af1RMejOZ5A@mail.gmail.com>
	<1389979208.27141.11.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Zhi Yong Wu <zwu.kernel@gmail.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:56924 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608AbaARE7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 23:59:15 -0500
Received: by mail-oa0-f44.google.com with SMTP id g12so5571234oah.3
        for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 20:59:15 -0800 (PST)
In-Reply-To: <1389979208.27141.11.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben,

I've never quite understood why flow management in aRFS has to be done
with separate messages, and if I recall this seems to mitigate
performance gains to a large extent. It seems like we should be able
to piggyback on a TX descriptor for a connection information about the
RX side for that connection, namely the rxhash and queue mapping.
State creation should be implicit by just seeing a new rxhash value,
tear down might be accomplished with a separate flag on the final TX
packet on the connection (this would need some additional logic in the
stack). Is this method not feasible in either NICs or virtio-net?

On Fri, Jan 17, 2014 at 9:20 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Sat, 2014-01-18 at 00:54 +0800, Zhi Yong Wu wrote:
>> On Fri, Jan 17, 2014 at 7:16 AM, Ben Hutchings
>> <bhutchings@solarflare.com> wrote:
> [...]
>> > However, to take advantage of ARFS on a physical net driver, it would be
>> > necessary to send a control request for part 2.
>> aRFS on a physical net driver? What is this physical net driver? I
>> thought that in order to enable aRFS, guest virtio_net driver should
>> send a control request to its emulated virtio_net NIC.
> [...]
>
> If the backend is connected to a macvlan device on top of a physical net
> device that supports ARFS, then there is further potential for improving
> performance by steering to the best physical RX queue and CPU as well as
> the best virtio_net RX queue and vCPU.
>
> Ben.
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
