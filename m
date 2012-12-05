From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH rfc] netfilter: two xtables matches
Date: Wed, 5 Dec 2012 23:35:15 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1212052333300.25806@nerf07.vanv.qr>
References: <1354735339-13402-1-git-send-email-willemb@google.com> <CA+FuTSeYvcdtNf7N=POD+RzsE01+WVsub6F_nqbn06RZyoWx8w@mail.gmail.com> <alpine.LNX.2.01.1212052100190.30908@nerf07.vanv.qr>
 <CA+FuTSfTVvQ8uBuSh47DRpShL5fyzNCaRXz39N1EaDqZCe8_+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, pablo@netfilter.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:56585 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932121Ab2LEWfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2012 17:35:17 -0500
In-Reply-To: <CA+FuTSfTVvQ8uBuSh47DRpShL5fyzNCaRXz39N1EaDqZCe8_+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday 2012-12-05 22:45, Willem de Bruijn wrote:
>>>The xt_priority match is a straighforward addition in the style of
>>>xt_mark, adding the option to filter on one more sk_buff field. I
>>>have an immediate application for this. The amount of code (in
>>>kernel + userspace) to add a single check proved quite large.
>>
>> Hm so yeah, can't we just place this in xt_mark.c?
>
>I'm happy to do so, but note that that breaks the custom of
>having one static struct xt_$NAME for each file xt_$NAME.[ch].

The custom is long gone (just look at xt_mark.c ;-),
because the module overhead is so much more than a function with
an assignment/readout.

>To avoid rule explosion, I considered an xt_skbuff match rule that
>applies the same mask operation, range and inversion tests, and
>takes a field id to select the sk_buff field to operate on. I think
>the BPF patch is a better long term solution.

I can't disagree.
