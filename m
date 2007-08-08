From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Thu, 9 Aug 2007 01:18:22 +0200
Message-ID: <9a8748490708081618p43cdcdfdn5de6f292247def5b@mail.gmail.com>
References: <20070808230733.GA17270@shell.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org
To: "Chris Snook" <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.176]:23299 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936379AbXHHXSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 19:18:24 -0400
Received: by el-out-1112.google.com with SMTP id j27so86630elf
        for <netdev@vger.kernel.org>; Wed, 08 Aug 2007 16:18:23 -0700 (PDT)
In-Reply-To: <20070808230733.GA17270@shell.boston.redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/08/2007, Chris Snook <csnook@redhat.com> wrote:
> From: Chris Snook <csnook@redhat.com>
>
> Some architectures currently do not declare the contents of an atomic_t to be
> volatile.  This causes confusion since atomic_read() might not actually read
> anything if an optimizing compiler re-uses a value stored in a register, which
> can break code that loops until something external changes the value of an
> atomic_t.  Avoiding such bugs requires using barrier(), which causes re-loads
> of all registers used in the loop, thus hurting performance instead of helping
> it, particularly on architectures where it's unnecessary.  Since we generally
> want to re-read the contents of an atomic variable on every access anyway,
> let's standardize the behavior across all architectures and avoid the
> performance and correctness problems of requiring the use of barrier() in
> loops that expect atomic_t variables to change externally.  This is relevant
> even on non-smp architectures, since drivers may use atomic operations in
> interrupt handlers.
>
> Signed-off-by: Chris Snook <csnook@redhat.com>
>

Hmm, I thought we were trying to move away from volatile since it is
very weakly defined and towards explicit barriers and locks...
Points to --> Documentation/volatile-considered-harmful.txt


-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
