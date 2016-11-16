From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net][v2] bpf: fix range arithmetic for bpf map access
Date: Wed, 16 Nov 2016 13:22:31 -0500 (EST)
Message-ID: <20161116.132231.466321381115973145.davem@davemloft.net>
References: <1479156336-6211-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jannh@google.com, ast@kernel.org, daniel@iogearbox.net,
        netdev@vger.kernel.org
To: jbacik@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45510 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752282AbcKPSWg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 13:22:36 -0500
In-Reply-To: <1479156336-6211-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josef Bacik <jbacik@fb.com>
Date: Mon, 14 Nov 2016 15:45:36 -0500

> I made some invalid assumptions with BPF_AND and BPF_MOD that could result in
> invalid accesses to bpf map entries.  Fix this up by doing a few things
> 
> 1) Kill BPF_MOD support.  This doesn't actually get used by the compiler in real
> life and just adds extra complexity.
> 
> 2) Fix the logic for BPF_AND, don't allow AND of negative numbers and set the
> minimum value to 0 for positive AND's.
> 
> 3) Don't do operations on the ranges if they are set to the limits, as they are
> by definition undefined, and allowing arithmetic operations on those values
> could make them appear valid when they really aren't.
> 
> This fixes the testcase provided by Jann as well as a few other theoretical
> problems.
> 
> Reported-by: Jann Horn <jannh@google.com>
> Signed-off-by: Josef Bacik <jbacik@fb.com>

Applied, thanks.
