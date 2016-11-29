From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net][v2] bpf: fix states equal logic for varlen access
Date: Tue, 29 Nov 2016 10:52:23 -0800
Message-ID: <20161129185221.GB22581@ast-mbp.thefacebook.com>
References: <1480440429-2531-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, ast@kernel.org,
        jannh@google.com, daniel@iogearbox.net, kernel-team@fb.com
To: Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34175 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751758AbcK2Sw1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 13:52:27 -0500
Received: by mail-pf0-f193.google.com with SMTP id y68so8770278pfb.1
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 10:52:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480440429-2531-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 12:27:09PM -0500, Josef Bacik wrote:
> If we have a branch that looks something like this
> 
> int foo = map->value;
> if (condition) {
>   foo += blah;
> } else {
>   foo = bar;
> }
> map->array[foo] = baz;
> 
> We will incorrectly assume that the !condition branch is equal to the condition
> branch as the register for foo will be UNKNOWN_VALUE in both cases.  We need to
> adjust this logic to only do this if we didn't do a varlen access after we
> processed the !condition branch, otherwise we have different ranges and need to
> check the other branch as well.
> 
> Fixes: 484611357c19 ("bpf: allow access into map value arrays")
> Reported-by: Jann Horn <jannh@google.com>
> Signed-off-by: Josef Bacik <jbacik@fb.com>

Thank you!
Acked-by: Alexei Starovoitov <ast@kernel.org>
