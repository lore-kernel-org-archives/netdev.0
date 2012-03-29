From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Q/RFC] BPF use in broader scope
Date: Thu, 29 Mar 2012 09:58:07 +0200
Message-ID: <1333007887.2325.268.camel@edumazet-glaptop>
References: <20120329074443.GB2098@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:50999 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295Ab2C2H6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 03:58:12 -0400
Received: by eekc41 with SMTP id c41so744190eek.19
        for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 00:58:11 -0700 (PDT)
In-Reply-To: <20120329074443.GB2098@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-03-29 at 09:44 +0200, Jiri Pirko wrote:
> Hi all.
> 
> I came to an idea of using BPF infrastructure currently used in kernel,
> for computing hashes selecting TX ports in team device. Since the same
> data (skb) are alalyzed/used as for socket filtering, BPF seems so be quite
> suitable for this. It would allow userspace daemon to specify various
> kinds of TX selection algorithms.
> 
> Here are proposed things to be done:
> 1) introduce in-kernel api for creating sk-unattached filters (I have
>    the patch cooked up already)
> 
> 2) extend current BPF machine to allow XOR operation. Not sure if this
>    is doable or what the best of doing this is.
> 
> 3) add possibility to pass some data to the machine via
>    pre-filling "Scratch Memory Store". I think this can be done easily
>    moving "u32 mem[BPF_MEMWORDS];" to bpf_func caller and pass it as the
>    second function parameter. That should not break anything.
> 
> Then the computed hash can be either stored into Scratch memory or returned
> directly (where ordinary sk filters return len).
> 
> Does this seems reasonable? Thoughts, comments?
> 

Sure it seems good ideas.

Maybe add :

4) be able to extend skb_flow_dissect() using BPF hooks
