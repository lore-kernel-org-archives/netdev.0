From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: don't zero out the info struct in
 bpf_obj_get_info_by_fd()
Date: Wed, 26 Jul 2017 17:03:19 -0700 (PDT)
Message-ID: <20170726.170319.672846958236203133.davem@davemloft.net>
References: <20170725221612.6937-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        kafai@fb.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56996 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751103AbdG0ADU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 20:03:20 -0400
In-Reply-To: <20170725221612.6937-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Tue, 25 Jul 2017 15:16:12 -0700

> The buffer passed to bpf_obj_get_info_by_fd() should be initialized
> to zeros.  Kernel will enforce that to guarantee we can safely extend
> info structures in the future.
> 
> Making the bpf_obj_get_info_by_fd() call in libbpf perform the zeroing
> is problematic, however, since some members of the info structures
> may need to be initialized by the callers (for instance pointers
> to buffers to which kernel is to dump translated and jited images).
> 
> Remove the zeroing and fix up the in-tree callers before any kernel
> has been released with this code.
> 
> As Daniel points out this seems to be the intended operation anyway,
> since commit 95b9afd3987f ("bpf: Test for bpf ID") is itself setting
> the buffer pointers before calling bpf_obj_get_info_by_fd().
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Applied, thanks Jakub.
