From: William Hua <william.hua@canonical.com>
Subject: Re: [PATCH] rhashtable: Always allocate at least one bucket lock
Date: Wed, 16 Dec 2015 02:33:30 -0500
Message-ID: <567113CA.8030108@canonical.com>
References: <20151216055310.GA23634@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:34840 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933018AbbLPHdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 02:33:32 -0500
Received: by mail-qk0-f172.google.com with SMTP id u65so32417906qkh.2
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 23:33:32 -0800 (PST)
In-Reply-To: <20151216055310.GA23634@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/2015 12:53 AM, Herbert Xu wrote:
> William Hua <william.hua@canonical.com> wrote:
>> No bucket locks are allocated when an rhashtable is initialized with
>> fewer than two elements. In this special case, we should allocate at
>> least one to prevent a segfault.
>>
>> Signed-off-by: William Hua <william.hua@canonical.com>
> 
> Huh? The minimum hash table size is 4.  How are you getting an
> rhashtable that's smaller than the required minimum?

I wasn't aware there was an enforced minimum size. I simply set the 
nelem_hint in the rhastable_params struct to 1, expecting it to grow as
needed. This caused a segfault afterwards when trying to insert an
element.
