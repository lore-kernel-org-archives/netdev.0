From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] iproute: build more easily on Android
Date: Wed, 11 Oct 2017 10:45:12 -0700
Message-ID: <20171011104512.2f2ed2db@xeon-e3>
References: <20171002170337.42235-1-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, enh@google.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:55201 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751934AbdJKRpU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 13:45:20 -0400
Received: by mail-pf0-f182.google.com with SMTP id m28so1458473pfi.11
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 10:45:19 -0700 (PDT)
In-Reply-To: <20171002170337.42235-1-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  3 Oct 2017 02:03:37 +0900
Lorenzo Colitti <lorenzo@google.com> wrote:

> iproute2 contains a bunch of kernel headers, including uapi ones.
> Android's libc uses uapi headers almost directly, and uses a
> script to fix kernel types that don't match what userspace
> expects.
> 
> For example: https://issuetracker.google.com/36987220 reports
> that our struct ip_mreq_source contains "__be32 imr_multiaddr"
> rather than "struct in_addr imr_multiaddr". The script addresses
> this by replacing the uapi struct definition with a #include
> <bits/ip_mreq.h> which contains the traditional userspace
> definition.
> 
> Unfortunately, when we compile iproute2, this definition
> conflicts with the one in iproute2's linux/in.h.
> 
> Historically we've just solved this problem by running "git rm"
> on all the iproute2 include/linux headers that break Android's
> libc.  However, deleting the files in this way makes it harder to
> keep up with upstream, because every upstream change to
> an include file causes a merge conflict with the delete.
> 
> This patch fixes the problem by moving the iproute2 linux headers
> from include/linux to include/uapi/linux.
> 
> Tested: compiles on ubuntu trusty (glibc)
> 
> Signed-off-by: Elliott Hughes <enh@google.com>
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
>

I went ahead and did this for 4.14 (and net-next).
Applied.
