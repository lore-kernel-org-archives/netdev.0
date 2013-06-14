From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [RFC PATCH net-next] mlx4_en: Do not set dev_id to port number
Date: Fri, 14 Jun 2013 22:55:34 +0300
Message-ID: <CAJZOPZLv9aidr7fV_2ntqy1DeZZGd9yUHZT1Dqbk=w-bssw69Q@mail.gmail.com>
References: <20130614150624.GA1316@fedora-17-guest.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	bhutchings@solarflare.com
To: Narendra_K@dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:63026 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134Ab3FNTzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 15:55:35 -0400
Received: by mail-qa0-f54.google.com with SMTP id n20so375633qaj.20
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 12:55:34 -0700 (PDT)
In-Reply-To: <20130614150624.GA1316@fedora-17-guest.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 14, 2013 at 6:06 PM, <Narendra_K@dell.com> wrote:
> Port number should not be stored in dev_id. 'dev_id' field was
> intended to be used to differentiate between multiple devices
> which share the same MAC address.

Maybe you want to say that dev_id is **now** intended to differentiate
between multiple devices which share the same MAC address? the reason
that mlx4_en and IPoIB use this field is

1. the Mellanox exposes one PCI function but has two ports with a
netdevice set on each

2. there was no standard way to expose the port number used by two
netdevices that share the same PCI function

3. here http://patchwork.ozlabs.org/patch/53547/ we were suggested by
the netdev maintainers to use that field

This patch introduces a regression and can't get in without a
replacment mechanism.

Or.
