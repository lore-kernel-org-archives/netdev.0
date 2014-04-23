From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: filter: initialize A and X registers
Date: Wed, 23 Apr 2014 09:53:37 +0200
Message-ID: <53577181.1000406@redhat.com>
References: <1398223137-5463-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54130 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750818AbaDWHxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 03:53:42 -0400
In-Reply-To: <1398223137-5463-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2014 05:18 AM, Alexei Starovoitov wrote:
> exisiting BPF verifier allows uninitialized access to registers,
> 'ret A' is considered to be a valid filter.
> So initialize A and X to zero to prevent leaking kernel memory
> In the future BPF verifier will be rejecting such filters
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Daniel Borkmann <dborkman@redhat.com>

I gave it some more thought, it's actually more than just 'ret A'
from your description, user programs could be used to generate code
like 'add X' or 'add #42' instead of a txa or load instruction [where
A is previously uninitialized], as it was always initialized to 0
before. We prevent to do a 'ret X', but X could be uninitialized and
then transferred over to taint A etc. So yeah, this patch is the most
simple way to prevent that w/o huge complexity. Therefore, it's
better this way:

Acked-by: Daniel Borkmann <dborkman@redhat.com>
