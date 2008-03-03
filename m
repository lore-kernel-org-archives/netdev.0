From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [rfc][patch 3/3] use SLAB_ALIGN_SMP
Date: Mon, 03 Mar 2008 15:15:42 +0100
Message-ID: <47CC080E.9010203@cosmosbay.com>
References: <20080303093449.GA15091@wotan.suse.de>	 <20080303093624.GC15091@wotan.suse.de>	 <47CBCAB0.2040604@cosmosbay.com>	 <20080303124142.GB13138@wotan.suse.de> <47CBF683.10201@cosmosbay.com>	 <20080303134622.GD13138@wotan.suse.de> <84144f020803030553s35a40dd8yf88585ccd5a599fd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nick Piggin <npiggin@suse.de>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Christoph Lameter <clameter@engr.sgi.com>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp25.orange.fr ([193.252.22.23]:28676 "EHLO smtp25.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751490AbYCCOPx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 09:15:53 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2557.orange.fr (SMTP Server) with ESMTP id 07CC51C000E8
	for <netdev@vger.kernel.org>; Mon,  3 Mar 2008 15:15:51 +0100 (CET)
In-Reply-To: <84144f020803030553s35a40dd8yf88585ccd5a599fd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pekka Enberg a =E9crit :
> Hi,
>
> On Mon, Mar 3, 2008 at 3:46 PM, Nick Piggin <npiggin@suse.de> wrote:
>  =20
>>  > Maybe we need to use three flags to separate the meanings ?
>>  >
>>  > SLAB_HINT_SMP_ALIGN
>>  > SLAB_HINT_HWCACHE_ALIGN
>>  > SLAB_HWCACHE_ALIGN /* strong requirement that two objects dont sh=
are a
>>  > cache line */
>>
>>  Possibly, but I'm beginning to prefer that strong requirements shou=
ld
>>  request the explicit alignment (they can even use cache_line_size()=
 after
>>  Pekka's patch to make it generic). I don't like how the name implie=
s
>>  that you get a guarantee, however I guess in practice people are us=
ing it
>>  more as a hint (or because they vaguely hope it makes their code ru=
n
>>  faster :))
>>    =20
>
> At least historically SLAB_HWCACHE_ALIGN has been just a hint,
> although slab tries very hard to satisfy it (see the comments in
> mm/slab.c). Why do we need stronger guarantees than that, btw?
>
>  =20
This reminds me a previous attempt of removing SLAB_HWCACHE_ALIGN

http://kernel.org/pub/linux/kernel/people/christoph/patch-archive/2007/=
2.6.21-rc6/remove_hwcache_align

At that time Christoph didnt took into account the CONFIG_SMP thing=20
(false sharing avoidance), but also that L1_CACHE_SIZE is a compile=20
constant, that can differs with cache_line_size()




