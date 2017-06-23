From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: possibly avoid extra masking for
 narrower load in verifier
Date: Fri, 23 Jun 2017 14:04:46 -0400 (EDT)
Message-ID: <20170623.140446.2147698536025020075.davem@davemloft.net>
References: <20170622220739.1482337-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, daniel@iogearbox.net, netdev@vger.kernel.org,
        kernel-team@fb.com
To: yhs@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34846 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754471AbdFWSEu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 14:04:50 -0400
In-Reply-To: <20170622220739.1482337-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yonghong Song <yhs@fb.com>
Date: Thu, 22 Jun 2017 15:07:39 -0700

> Commit 31fd85816dbe ("bpf: permits narrower load from bpf program
> context fields") permits narrower load for certain ctx fields.
> The commit however will already generate a masking even if
> the prog-specific ctx conversion produces the result with
> narrower size.
> 
> For example, for __sk_buff->protocol, the ctx conversion
> loads the data into register with 2-byte load.
> A narrower 2-byte load should not generate masking.
> For __sk_buff->vlan_present, the conversion function
> set the result as either 0 or 1, essentially a byte.
> The narrower 2-byte or 1-byte load should not generate masking.
> 
> To avoid unnecessary masking, prog-specific *_is_valid_access
> now passes converted_op_size back to verifier, which indicates
> the valid data width after perceived future conversion.
> Based on this information, verifier is able to avoid
> unnecessary marking.
> 
> Since we want more information back from prog-specific
> *_is_valid_access checking, all of them are packed into
> one data structure for more clarity.
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Yonghong Song <yhs@fb.com>

Applied, thank you.
