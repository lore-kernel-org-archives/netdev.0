From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: Add max rate tx queue attribute
Date: Wed, 11 Mar 2015 22:11:07 +0200
Message-ID: <CAJ3xEMiKbPs6eMkVzUEgu-GWqTd7x56CRtuqo5J9+xdUZEjjAA@mail.gmail.com>
References: <1426079690-28271-1-git-send-email-ogerlitz@mellanox.com>
	<1426079690-28271-2-git-send-email-ogerlitz@mellanox.com>
	<55008E78.8020607@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Matan Barak <matanb@mellanox.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:34285 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895AbbCKULI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 16:11:08 -0400
Received: by obcwp18 with SMTP id wp18so11509096obc.1
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 13:11:07 -0700 (PDT)
In-Reply-To: <55008E78.8020607@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2015, John Fastabend <john.r.fastabend@intel.com> wrote:
> On 03/11/2015 06:14 AM, Or Gerlitz wrote:

>> This adds a tx_maxrate attribute to the tx queue sysfs entry allowing
>> for max-rate limiting. Along with DCB-ETS and BQL this provides another
>> knob to tune queue performance. The limit units are Mbps.
>>
>> By default it is disabled. To disable the rate limitation after it
>> has been set for a queue, it should be set to zero.

>>  include/linux/netdevice.h |    9 ++++++
>>  net/core/net-sysfs.c      |   70 +++++++++++++++++++++++++++++++++++++--------

> hmm I'm not sure sysfs is entirely the correct interface although it is convenient.

Very convenient indeed, and we use it for bunch of other tunables
(xps, affinities and such). So I would vote for keeping it.

>  Did you consider porting to netlink? To be honest I can't remember why
>  I didn't do it netlink to start with. I think at the time
> I was more interested in the controller, feedback loop aspect. Basically
> I was dynamically managing the rate limiters across NICs from an agent to
> try and manage some types of congestion.

Sure, but we can add later netlink interface on top of the basic patch
that defines the ndo. I assume you refer to rtnetlink and the
changelink callback? can a driver instantiate it w.o having
newlink/dellink bindings?
