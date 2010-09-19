From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] netfilter: unregister nf hooks, matches and targets in
 the reverse order
Date: Sun, 19 Sep 2010 13:58:17 +0800
Message-ID: <AANLkTi=AhK0jDM8WEf5tHhervKUpB6f4MR+mNx2moYuC@mail.gmail.com>
References: <1283436908-10744-1-git-send-email-xiaosuo@gmail.com> <4C91033B.6070902@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59715 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078Ab0ISF6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Sep 2010 01:58:38 -0400
In-Reply-To: <4C91033B.6070902@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 16, 2010 at 1:32 AM, Patrick McHardy <kaber@trash.net> wrote:
> Am 02.09.2010 16:15, schrieb Changli Gao:
>> Since we register nf hooks, matches and targets in order, we'd better
>> unregister them in the reverse order.
>
> Why? Is there a specific bug you've noticed?
>

No, there isn't any bug. I just think unregistering them in the
reverse order is more resonable, like the rollback when failing. And
the code patched generates less object:

The original:

00000000000009c9 <xt_unregister_matches>:
     9c9:       55                      push   %rbp
     9ca:       48 89 e5                mov    %rsp,%rbp
     9cd:       41 55                   push   %r13
     9cf:       41 89 f5                mov    %esi,%r13d
     9d2:       41 54                   push   %r12
     9d4:       49 89 fc                mov    %rdi,%r12
     9d7:       53                      push   %rbx
     9d8:       31 db                   xor    %ebx,%ebx
     9da:       48 83 ec 08             sub    $0x8,%rsp
     9de:       eb 0e                   jmp    9ee <xt_unregister_matches+0x25>
     9e0:       4c 89 e7                mov    %r12,%rdi
     9e3:       ff c3                   inc    %ebx
     9e5:       49 83 c4 78             add    $0x78,%r12
     9e9:       e8 00 00 00 00          callq  9ee <xt_unregister_matches+0x25>
     9ee:       44 39 eb                cmp    %r13d,%ebx
     9f1:       72 ed                   jb     9e0 <xt_unregister_matches+0x17>
     9f3:       41 59                   pop    %r9
     9f5:       5b                      pop    %rbx
     9f6:       41 5c                   pop    %r12
     9f8:       41 5d                   pop    %r13
     9fa:       c9                      leaveq
     9fb:       c3                      retq

The patched:

00000000000009c9 <xt_unregister_matches>:
     9c9:       55                      push   %rbp
     9ca:       48 89 e5                mov    %rsp,%rbp
     9cd:       41 54                   push   %r12
     9cf:       41 89 f4                mov    %esi,%r12d
     9d2:       53                      push   %rbx
     9d3:       48 89 fb                mov    %rdi,%rbx
     9d6:       eb 13                   jmp    9eb <xt_unregister_matches+0x22>
     9d8:       41 ff cc                dec    %r12d
     9db:       44 89 e7                mov    %r12d,%edi
     9de:       48 6b ff 78             imul   $0x78,%rdi,%rdi
     9e2:       48 8d 3c 3b             lea    (%rbx,%rdi,1),%rdi
     9e6:       e8 00 00 00 00          callq  9eb <xt_unregister_matches+0x22>
     9eb:       45 85 e4                test   %r12d,%r12d
     9ee:       75 e8                   jne    9d8 <xt_unregister_matches+0xf>
     9f0:       5b                      pop    %rbx
     9f1:       41 5c                   pop    %r12
     9f3:       c9                      leaveq
     9f4:       c3                      retq

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
