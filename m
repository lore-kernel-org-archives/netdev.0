From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net][v2] bpf: fix range arithmetic for bpf map access
Date: Mon, 14 Nov 2016 19:10:17 -0800
Message-ID: <20161115031016.GA10323@ast-mbp.thefacebook.com>
References: <1479156336-6211-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jannh@google.com, ast@kernel.org, daniel@iogearbox.net,
        davem@davemloft.net, netdev@vger.kernel.org
To: Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35257 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941131AbcKODKX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 22:10:23 -0500
Received: by mail-pg0-f68.google.com with SMTP id p66so10530074pga.2
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 19:10:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1479156336-6211-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2016 at 03:45:36PM -0500, Josef Bacik wrote:
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

lgtm.
Acked-by: Alexei Starovoitov <ast@kernel.org>

Jann, could you please double check the logic.
Thanks!
