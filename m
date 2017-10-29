From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [RFC] please clarify local_irq_disable() in
 pcpu_freelist_populate()
Date: Sun, 29 Oct 2017 21:14:39 +0100
Message-ID: <20171029201438.g6f7eivvgtofpdvq@linutronix.de>
References: <20171027222354.bf3wv4ldnrmc5pbx@linutronix.de>
 <72432216-c082-2f79-65bd-ee082fa369dc@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: tglx@linutronix.de, peterz@infradead.org,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:38925 "EHLO
        Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752039AbdJ2UOw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Oct 2017 16:14:52 -0400
Content-Disposition: inline
In-Reply-To: <72432216-c082-2f79-65bd-ee082fa369dc@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-10-27 19:18:40 [-0700], Alexei Starovoitov wrote:
> pcpu_freelist_push() is called by bpf programs from atomic context.

so raw would still be correct because the content is locked.

> lockdep thinks that __pcpu_freelist_push() can be called recursively
> in the middle of pcpu_freelist_populate's loop and will deadlock
> which is not the case here. That's why local_irq_save() is there.
> Just to silence lockdep.

do you mind giving me bunch of test-cases so I can test it myself?

> While developing pcpu_freelist I've benchmarked many different
> approaches. Some of the numbers are in
> commit 6c9059817432 ("bpf: pre-allocate hash map elements")
> iirc I passed on llist, since llist_del_first still needs a lock,
> so doesn't really help.

Okay. I will look that up.

Sebastian
