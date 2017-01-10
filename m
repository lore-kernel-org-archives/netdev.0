From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next] net: ipv6: put autoconf routes into
 per-interface tables
Date: Wed, 11 Jan 2017 02:47:55 +0900
Message-ID: <CAKD1Yr3nfOp1LNfvVuTGZyThwu8Z+gaSN-DVaa11ZJYR+tMemg@mail.gmail.com>
References: <20170106153026.24785-1-lorenzo@google.com> <37df3b18-d17b-5875-7b44-db40be7b459c@cumulusnetworks.com>
 <CAKD1Yr2U2Oh5yvHE7Znfc9mHzM4K6B_kU82Qctpcsmnt3y5GdQ@mail.gmail.com>
 <e282793e-4057-7fe6-8322-e1899d873ae2@cumulusnetworks.com>
 <CAKD1Yr21W2Ce6mhAqfz+mFUPTn+xn3K_Lz2q5LA27f6V=9tTSQ@mail.gmail.com>
 <161222cb-5c61-d016-bc0f-2453fb0408b7@cumulusnetworks.com>
 <CAKD1Yr0BnYNTYtCBHLy=KuhX3_23p8eQst61CoC0BHEr5PVkjQ@mail.gmail.com>
 <bbcab8bb-6a2a-6b90-f6a2-ad840a2c389c@cumulusnetworks.com> <un3fkd-lod.ln1@banana.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Andrey Jr. Melnikov" <temnota.am@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f50.google.com ([209.85.213.50]:35911 "EHLO
        mail-vk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753122AbdAJRsS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 12:48:18 -0500
Received: by mail-vk0-f50.google.com with SMTP id t8so31590346vke.3
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 09:48:17 -0800 (PST)
In-Reply-To: <un3fkd-lod.ln1@banana.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2017 at 10:21 PM, Andrey Jr. Melnikov
<temnota.am@gmail.com> wrote:
>
> > >>> I have no firsthand experience of this myself, but if the problems
> > >>> that Andrey reports above in this thread are real, then those would
> > >>> indicate that the code is not well-supported. Being unable to accept
> > >>> DAD is a pretty serious issue. Andrey, what version of the kernel did
> > >>> you see this on?
>
> Good catch. I'm running 4.8 without this patch. Current 4.10-rc works. Sorry
> for noise.

Ack. As I said before, I haven't seen this myself. Shouldn't have made
assertions without firsthand evidence.

That said, I think this patch is useful even though autoconf on VRFs
works the same way. One reason is the example I provided above: it
works even for interfaces that don't exist yet, whereas a VRF has to
be created ahead of time, which means that the interface cannot
immediately come up and receive an RA or its configuration will be
incorrect.

I also think that from a configuration perspective it's not
necessarily useful to have one VRF for every interface, but that sort
of depends on your point of view. Perhaps it's fine on a client system
to have both vrf-wlan0 and wlan0, and vrf-eth0 and eth0. That might be
confusing to users but maybe users don't really care?

More in general I think that using a VRFs is buying into a bigger set
of assumptions/restrictions than this patch does. For example, if I'm
reading ipv6_dev_get_saddr correctly, once you put an interface in a
VRF you can't really use the weak host model any more, because the
stack won't pick a source address from outside the VRF if the route
lookup returned a route in the VRF. Turning on the functionality in
patch is a more minimal change that only affects autoconf.
