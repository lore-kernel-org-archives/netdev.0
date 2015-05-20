From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net] net: sched: fix call_rcu() race on classifier module
 unloads
Date: Wed, 20 May 2015 11:32:56 -0700
Message-ID: <555CD358.7090604@plumgrid.com>
References: <9f44c4c5d2ad81e7d7ef828b9e60bd308fc7caf9.1432134471.git.daniel@iogearbox.net> <CAHA+R7PMC7Zi0gqAUFzfWfJ_CLTmNYqjSgAQH2kKVONEy_3gZQ@mail.gmail.com> <555CCE89.10503@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, subramanian.vijay@gmail.com,
	netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:33625 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753505AbbETSdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 14:33:00 -0400
Received: by iebgx4 with SMTP id gx4so45960860ieb.0
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 11:32:59 -0700 (PDT)
In-Reply-To: <555CCE89.10503@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/20/15 11:12 AM, Daniel Borkmann wrote:
>
> Effectively, every in-tree classifier (rsvp is the only exception)
> is making use of call_rcu(). Moreover, moving this into every
> ->destroy() handler would also be unnecessary overhead, imho, as
> this is only relevant when we actually _unload_ a module.

+1
indeed unregister_tcf_proto_ops() is only called at module unload time.
So there is no overhead from this rcu_barrier(). It's actually
mandatory. All modules with rcu callbacks should do that.

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
