From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [net PATCH] fib_trie: Drop unnecessary calls to leaf_pull_suffix
Date: Mon, 27 Jul 2015 15:02:07 -0600
Message-ID: <55B69C4F.40506@cumulusnetworks.com>
References: <55B6612C.7050506@cumulusnetworks.com> <20150727195631.26840.93266.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:38639 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753817AbbG0VCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 17:02:10 -0400
Received: by iggf3 with SMTP id f3so94562106igg.1
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 14:02:09 -0700 (PDT)
In-Reply-To: <20150727195631.26840.93266.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/27/15 2:08 PM, Alexander Duyck wrote:
> It was reported that update_suffix was taking a long time on systems where
> a large number of leaves were attached to a single node.  As it turns out
> fib_table_flush was calling update_suffix for each leaf that didn't have all
> of the aliases stripped from it.  As a result, on this large node removing
> one leaf would result in us calling update_suffix for every other leaf on
> the node.
>
> The fix is to just remove the calls to leaf_pull_suffix since they are
> redundant as we already have a call in resize that will go through and
> update the suffix length for the node before we exit out of
> fib_table_flush or fib_table_flush_external.
>
> Reported-by: David Ahern<dsa@cumulusnetworks.com>
> Signed-off-by: Alexander Duyck<alexander.h.duyck@redhat.com>
> ---
>
> This patch should apply to linux-4.1.y and newer kernels.
>
> I've done a bit of testing on my system and I no longer see update_suffix
> dominating the performance traces.  David if you can test with this patch
> to see if you still see the issue I would appreciate it.
>

Works for me. Thanks.

Tested-by: David Ahern <dsa@cumulusnetworks.com>
