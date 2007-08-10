From: David Miller <davem@davemloft.net>
Subject: Re: [patch 27/28] Introduce U16_MAX and U32_MAX
Date: Fri, 10 Aug 2007 15:38:19 -0700 (PDT)
Message-ID: <20070810.153819.76325424.davem@davemloft.net>
References: <200708102112.l7ALCA2M009460@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, satyam@infradead.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38172
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765980AbXHJWiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:38:22 -0400
In-Reply-To: <200708102112.l7ALCA2M009460@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Fri, 10 Aug 2007 14:12:10 -0700

> From: Satyam Sharma <satyam@infradead.org>
> 
> ... in kernel.h and clean up home-grown macros elsewhere in the tree.
> 
> Leave out the one in reiserfs_fs.h as it is in the userspace-visible part
> of that header. Still, #undef the (equivalent) kernel version there to
> avoid seeing "redefined, previous definition was here" gcc warnings.
> 
> [akpm@linux-foundation.org: fix U16_MAX, U32_MAX defns]
> Signed-off-by: Satyam Sharma <satyam@infradead.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

I won't apply this one, for two reasons:

1) The reiserfs definition is better, it is _type_ based.
   Please use (~(__u16)0) and (~(__u32)0), respectively.

2) The reiserfs definition is going to define an equivalent
   value, so just adding an #undef and still letting reiserfs
   override is wrong.  Why put a common define in kernel.h
   if other headers still keep their own crufty copy too?
