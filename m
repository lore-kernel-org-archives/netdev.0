From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bpf: rather use get_random_int for randomizations
Date: Wed, 18 May 2016 06:20:34 -0700
Message-ID: <1463577634.18194.100.camel@edumazet-glaptop3.roam.corp.google.com>
References: <24461974e8402395c12b3e36b9ac7935b88ef1c2.1463572456.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34461 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895AbcERNUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 09:20:37 -0400
Received: by mail-pf0-f196.google.com with SMTP id 145so5106467pfz.1
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 06:20:36 -0700 (PDT)
In-Reply-To: <24461974e8402395c12b3e36b9ac7935b88ef1c2.1463572456.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-05-18 at 14:14 +0200, Daniel Borkmann wrote:
> Start address randomization and blinding in BPF currently use
> prandom_u32(). prandom_u32() values are not exposed to unpriviledged
> user space to my knowledge, but given other kernel facilities such as
> ASLR, stack canaries, etc make use of stronger get_random_int(), we
> better make use of it here as well given blinding requests successively
> new random values. get_random_int() has minimal entropy pool depletion,
> is not cryptographically secure, but doesn't need to be for our use
> cases here.

Well, if it is not crypto secure, what is the point using it instead of
prandom_u32() ?

I do not think changing this is fundamentally changing something, it
looks like code churn or magic incantation to me.

There is little amount of entropy since the hole is constrained by
PAGE_SIZE. 

Have you had any report of an actual attack ?

If yes, we seriously need to reconsider this whole schem.
