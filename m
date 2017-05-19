From: David Miller <davem@davemloft.net>
Subject: Re: Alignment in BPF verifier
Date: Fri, 19 May 2017 16:39:57 -0400 (EDT)
Message-ID: <20170519.163957.1950740987459934279.davem@davemloft.net>
References: <db8cd2e8-9f51-dc8b-5e55-4c75d13d4858@fb.com>
        <a0a47297-4765-3ba0-3ea2-013dda40e84a@solarflare.com>
        <bed5b512-6069-53cc-f128-05be05f89889@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, daniel@iogearbox.net, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57388 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755623AbdESUkB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 16:40:01 -0400
In-Reply-To: <bed5b512-6069-53cc-f128-05be05f89889@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Fri, 19 May 2017 21:00:13 +0100

> Well, I've managed to get somewhat confused by reg->id.
> In particular, I'm unsure which bpf_reg_types can have an id, and what
>  exactly it means.  There seems to be some code that checks around map value
>  pointers, which seems strange as maps have fixed sizes (and the comments in
>  enum bpf_reg_type make it seem like id is a PTR_TO_PACKET thing) - is this
>  maybe because of map-of-maps support, can the contained maps have differing
>  element sizes?  Or do we allow *(map_value + var + imm), if map_value + var
>  was appropriately bounds-checked?
> 
> Does the 'id' identify the variable that was added to an object pointer, or
>  the object itself?  Or does it blur these and identify (what the comment in
>  enum bpf_reg_type calls) "skb->data + (u16) var"?

The reg->id value changes any time a variable gets added to a packet
pointer.

You will also notice right now that only packet pointers have their
alignment tracked.

I have changes pending that will do that for MAP pointers too, but
it needs more work.
