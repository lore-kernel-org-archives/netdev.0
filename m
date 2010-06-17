From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: bnx2 fails to compile on parisc because of missing get_dma_ops()
Date: Thu, 17 Jun 2010 00:00:01 -0400
Message-ID: <AANLkTimj3HBEMYfEBHlm9YNY53aipjFuXOsX2aMxwDoK@mail.gmail.com>
References: <AANLkTilSfOwwT87mgDcWBogL4gPnM7VBTOALKpZv_upN@mail.gmail.com>
	<C27F8246C663564A84BB7AB3439772421B79CBCA1C@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: James Bottomley <JBottomley@novell.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:52314 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756869Ab0FQEAE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jun 2010 00:00:04 -0400
In-Reply-To: <C27F8246C663564A84BB7AB3439772421B79CBCA1C@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 16, 2010 at 11:53 PM, Michael Chan wrote:
> Mike Frysinger wrote:
>> > The commit that causes the problem:
>> >
>> > commit a33fa66bcf365ffe5b79d1ae1d3582cc261ae56e
>> > Author: Michael Chan <mchan@broadcom.com>
>> > Date: =A0 Thu May 6 08:58:13 2010 +0000
>> >
>> > =A0 =A0bnx2: Add prefetches to rx path.
>> >
>> > Looks fairly innocuous by the description.
>> >
>> > Should parisc have a get_dma_ops()? =A0We don't need one
>> because our dma
>> > ops are per platform not per bus.
>>
>> looks like it'll be broken on more than just parisc:
>> $ grep get_dma_ops arch/*/include/asm/ -rl | cut -d/ -f 2
>> alpha
>> ia64
>> microblaze
>> powerpc
>> sh
>> sparc
>> x86
>
> Most of these archs use the dma functions in:
>
> <asm-genric/dma-mapping-common.h>
>
> so it's not a problem.

the grep is showing only the arches that define get_dma_ops (and so
the new code works).  you'd have to invert the list to see the ones
which do not define get_dma_ops(), and the inverted list is larger.
that was merely my point.
-mike
