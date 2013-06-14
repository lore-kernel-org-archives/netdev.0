From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH net-next] mlx4_en: Do not set dev_id to port number
Date: Fri, 14 Jun 2013 21:14:42 +0100
Message-ID: <1371240882.1940.18.camel@bwh-desktop.uk.level5networks.com>
References: <20130614150624.GA1316@fedora-17-guest.blr.amer.dell.com>
	 <CAJZOPZLv9aidr7fV_2ntqy1DeZZGd9yUHZT1Dqbk=w-bssw69Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <Narendra_K@dell.com>, <netdev@vger.kernel.org>,
	<ogerlitz@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6836 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753116Ab3FNUOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 16:14:47 -0400
In-Reply-To: <CAJZOPZLv9aidr7fV_2ntqy1DeZZGd9yUHZT1Dqbk=w-bssw69Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-14 at 22:55 +0300, Or Gerlitz wrote:
> On Fri, Jun 14, 2013 at 6:06 PM, <Narendra_K@dell.com> wrote:
> > Port number should not be stored in dev_id. 'dev_id' field was
> > intended to be used to differentiate between multiple devices
> > which share the same MAC address.
> 
> Maybe you want to say that dev_id is **now** intended to differentiate
> between multiple devices which share the same MAC address?

That was the original intent but it wasn't well-documented.  (Hence
several of us driver writers have made a similar mistake.)

> the reason that mlx4_en and IPoIB use this field is
> 
> 1. the Mellanox exposes one PCI function but has two ports with a
> netdevice set on each
> 
> 2. there was no standard way to expose the port number used by two
> netdevices that share the same PCI function
> 
> 3. here http://patchwork.ozlabs.org/patch/53547/ we were suggested by
> the netdev maintainers to use that field
> 
> This patch introduces a regression and can't get in without a
> replacment mechanism.

If you have userland tools relying on this then I agree it should be
left alone, but maybe add a comment explaining why the field is used in
an unusual way.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
