From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] ebpf: verifier: check that call reg with ARG_ANYTHING
 is initialized
Date: Thu, 12 Mar 2015 09:53:59 -0700
Message-ID: <5501C4A7.8020803@plumgrid.com>
References: <8bb5d2d9c8d471c1161ae60ea92141aef00a4fc8.1426172976.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: challa@noironetworks.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:33802 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932148AbbCLQx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 12:53:56 -0400
Received: by iecsl2 with SMTP id sl2so48928097iec.1
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 09:53:55 -0700 (PDT)
In-Reply-To: <8bb5d2d9c8d471c1161ae60ea92141aef00a4fc8.1426172976.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/12/15 9:21 AM, Daniel Borkmann wrote:
> I noticed that a helper function with argument type ARG_ANYTHING does
> not need to have an initialized value (register).
>
> This can worst case lead to unintented stack memory leakage in future
> helper functions if they are not carefully designed, or unintended
> application behaviour in case the application developer was not careful
> enough to match a correct helper function signature in the API.
>
> The underlying issue is that ARG_ANYTHING should actually be split
> into two different semantics:
>
>    1) ARG_DONTCARE for function arguments that the helper function
>       does not care about (in other words: the default for unused
>       function arguments), and
>
>    2) ARG_ANYTHING that is an argument actually being used by a
>       helper function and *guaranteed* to be an initialized register.
>
> The current risk is low: ARG_ANYTHING is only used for the 'flags'
> argument (r4) in bpf_map_update_elem() that internally does strict
> checking.
>
> Fixes: 17a5267067f3 ("bpf: verifier (add verifier core)")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>   I'm fine with this going to net-next, but it also applies to net.

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

nice catch. you understood verifier so well :)
Also agree that net-next is enough.
