From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net 3/3] sched: cls_flow: fix panic on filter replace
Date: Fri, 17 Jul 2015 14:07:33 -0700
Message-ID: <55A96E95.8050804@gmail.com>
References: <cover.1437163466.git.daniel@iogearbox.net> <e9ed6bbcf7e9d9b3fdbd3dd0b5117d9a284b4399.1437163466.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, jiri@resnulli.us, jhs@mojatatu.com,
	edumazet@google.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:35639 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752546AbbGQVHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 17:07:16 -0400
Received: by obbop1 with SMTP id op1so72779671obb.2
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 14:07:15 -0700 (PDT)
In-Reply-To: <e9ed6bbcf7e9d9b3fdbd3dd0b5117d9a284b4399.1437163466.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-07-17 01:38 PM, Daniel Borkmann wrote:
> The following test case causes a NULL pointer dereference in cls_flow:
> 
>   tc filter add dev foo parent 1: handle 0x1 flow hash keys dst action ok
>   tc filter replace dev foo parent 1: pref 49152 handle 0x1 \
>             flow hash keys mark action drop
> 
> To be more precise, actually two different panics are fixed, the first
> occurs because tcf_exts_init() is not called on the newly allocated
> filter when we do a replace. And the second panic uncovered after that
> happens since the arguments of list_replace_rcu() are swapped, the old
> element needs to be the first argument and the new element the second.
> 
> Fixes: 70da9f0bf999 ("net: sched: cls_flow use RCU")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  net/sched/cls_flow.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 

Thanks again, I must have missed running replace tests in these cases.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
