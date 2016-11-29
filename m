From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net][v2] bpf: fix states equal logic for varlen access
Date: Tue, 29 Nov 2016 20:09:37 +0100
Message-ID: <583DD271.2020900@iogearbox.net>
References: <1480440429-2531-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Josef Bacik <jbacik@fb.com>, davem@davemloft.net,
        netdev@vger.kernel.org, ast@kernel.org, jannh@google.com,
        kernel-team@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54200 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbcK2TJl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 14:09:41 -0500
In-Reply-To: <1480440429-2531-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2016 06:27 PM, Josef Bacik wrote:
> If we have a branch that looks something like this
>
> int foo = map->value;
> if (condition) {
>    foo += blah;
> } else {
>    foo = bar;
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

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
