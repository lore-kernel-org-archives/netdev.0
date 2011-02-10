From: Octavian Purdila <tavi.purdila@gmail.com>
Subject: Re: [PATCH] Add JMEMCMP to Berkeley Packet Filters
Date: Thu, 10 Feb 2011 17:27:15 +0200
Message-ID: <AANLkTimOzvMx0FUaqxaa2QVV2FzsuhP8gQVX_CFmhiNR@mail.gmail.com>
References: <1297341067-12264-1-git-send-email-ian.molton@collabora.co.uk>
	<1297341067-12264-2-git-send-email-ian.molton@collabora.co.uk>
	<1297344292.2493.3.camel@edumazet-laptop>
	<4D53E9BE.4030500@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	rdunlap@xenotime.net, isdn@linux-pingi.de, paulus@samba.org,
	arnd@arndb.de, davem@davemloft.net, herbert@gondor.apana.org.au,
	ebiederm@xmission.com, alban.crequy@collabora.co.uk,
	astanciu@ixiacom.com
To: Ian Molton <ian.molton@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:61020 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756274Ab1BJP1Q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 10:27:16 -0500
Received: by gwj20 with SMTP id 20so624929gwj.19
        for <netdev@vger.kernel.org>; Thu, 10 Feb 2011 07:27:16 -0800 (PST)
In-Reply-To: <4D53E9BE.4030500@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 10, 2011 at 3:35 PM, Ian Molton <ian.molton@collabora.co.uk=
> wrote:
> On 10/02/11 13:24, Eric Dumazet wrote:
>
> Hi!
>
> Thanks for reviewing! :)
>
>>> * Can sk_run_filter() be called in a context where kmalloc(GFP_KERN=
EL) is
>>> =A0 not allowed (I think not)
>>
>> You cannot use GFP_KERNEL in sk_run_filter() : We run in {soft}irq m=
ode,
>> in input path.
>
> Ok, that can be sorted.
>
>>> * Data section allocated with second call to sock_kmalloc().
>>> * Should the patch be broken into two - one to add the data uploadi=
ng,
>>> =A0 one to add the JMEMCMP insn. ?
>>
>> May I ask why it is needed at all ?
>
> So we can match strings in packet filters... I don't think I understa=
nd the
> question...
>

Adding a data section (some sort of persistent memory storage that the
filter can access) is also useful for creating capture triggers, e.g.
starting capturing after a marker packet has arrived.
