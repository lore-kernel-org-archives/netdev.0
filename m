From: David Miller <davem@davemloft.net>
Subject: Re: [lkp-robot] [bpf] de05014aba:
 BUG:sleeping_function_called_from_invalid_context_at_mm/slab.h
Date: Mon, 15 May 2017 14:57:25 -0400 (EDT)
Message-ID: <20170515.145725.74958807751910010.davem@davemloft.net>
References: <20170427062449.80290-2-kafai@fb.com>
        <20170515081438.GI15250@yexl-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, netdev@vger.kernel.org, daniel@iogearbox.net,
        hannes@stressinduktion.org, ast@fb.com, kernel-team@fb.com,
        lkp@01.org
To: xiaolong.ye@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38556 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966030AbdEOS5c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 14:57:32 -0400
In-Reply-To: <20170515081438.GI15250@yexl-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kernel test robot <xiaolong.ye@intel.com>
Date: Mon, 15 May 2017 16:14:38 +0800

> commit: de05014aba8054e1353b720b814a0cd8ea7594e5 ("bpf: Introduce bpf_prog ID")
> url: https://github.com/0day-ci/linux/commits/Martin-KaFai-Lau/bpf-Introduce-bpf_prog-ID/20170428-025859

Indeed, we can't use GFP_USER in the call to idr_alloc_cyclic() if it is
going to run with the prog_idr_lock spinlock held.
