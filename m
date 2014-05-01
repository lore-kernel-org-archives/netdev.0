From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 1/3] net: filter: simplify label names from
 jump-table
Date: Thu, 01 May 2014 11:50:13 -0700
Message-ID: <1398970213.29914.211.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1398960996-10469-1-git-send-email-dborkman@redhat.com>
	  <1398960996-10469-2-git-send-email-dborkman@redhat.com>
	 <1398964810.29914.200.camel@edumazet-glaptop2.roam.corp.google.com>
	 <536286E5.1080309@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ast@plumgrid.com, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:56170 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881AbaEASuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 14:50:16 -0400
Received: by mail-pa0-f43.google.com with SMTP id rd3so4073611pab.2
        for <netdev@vger.kernel.org>; Thu, 01 May 2014 11:50:15 -0700 (PDT)
In-Reply-To: <536286E5.1080309@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-01 at 19:39 +0200, Daniel Borkmann wrote:

> Well, if you review the code itself in filter.c it makes it hard
> to read and review, with this patch, you'll immediately get the
> label name and what it actually does, so I think it's quite convenient
> and way more readable by itself. For grepping, you can always add
> subdirectories you're searching for, besides that I don't think
> that everything in the kernel needs to have unique names only so
> that one can grep for it among the whole tree.



Considering that Alexei claimed :

+Internal BPF is a general purpose RISC instruction set. Not every register and
+every instruction are used during translation from original BPF to new format.
+For example, socket filters are not using 'exclusive add' instruction, but
+tracing filters may do to maintain counters of events, for example. Register R9
+is not used by socket filters either, but more complex filters may be running
+out of registers and would have to resort to spill/fill to stack.

I tried to verify this claim and I could not.

After your patch, it will be really this :

"We, Daniel and Alexei, hereby certify that this code is 100% safe.

 If you Eric, or anyone else, want to check, you'll have to grep in
appropriate places, and use your brain as we did."

I find very worrying all this stuff. This looks like you guys make
everything possible to make it absolutely unmaintainable.
