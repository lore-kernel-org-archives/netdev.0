From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] selftests/bpf: get rid of -D__x86_64__
Date: Wed, 03 May 2017 13:35:12 -0400 (EDT)
Message-ID: <20170503.133512.310640909764585408.davem@davemloft.net>
References: <20170503.095251.353611409224180200.davem@davemloft.net>
        <20170503.120634.1673036085707133455.davem@davemloft.net>
        <6a5fa930-cb76-8eee-94c7-7c5fe8fb8cdc@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40002 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753312AbdECRfV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 13:35:21 -0400
In-Reply-To: <6a5fa930-cb76-8eee-94c7-7c5fe8fb8cdc@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Wed, 3 May 2017 09:54:42 -0700

> /usr/include/asm/types.h -> asm-generic/int-ll64.h
> as far as I can see that should be the same on most archs.
> Why doesn't it work for sparc?

You can't assume anything about the kernel headers installed,
on my debian Sparc box /usr/include/asm/types.h is below.

They do things this way to facilitate multiarch building.  I think
it's pretty reasonable.

#ifndef _SPARC_TYPES_H
#define _SPARC_TYPES_H
/*
 * This file is never included by application software unless
 * explicitly requested (e.g., via linux/types.h) in which case the
 * application is Linux specific so (user-) name space pollution is
 * not a major issue.  However, for interoperability, libraries still
 * need to be careful to avoid a name clashes.
 */

#if defined(__sparc__)

#include <asm-generic/int-ll64.h>

#ifndef __ASSEMBLY__

typedef unsigned short umode_t;

#endif /* __ASSEMBLY__ */

#endif /* defined(__sparc__) */

#endif /* defined(_SPARC_TYPES_H) */
