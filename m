From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 3/6] myri10ge - Driver header files
Date: Wed, 10 May 2006 14:57:57 -0700
Message-ID: <adalkt97day.fsf@cisco.com>
References: <446259A0.8050504@myri.com> <44625CD2.8040100@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Andrew J. Gallatin" <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:37965 "EHLO
	sj-iport-4.cisco.com") by vger.kernel.org with ESMTP
	id S932305AbWEJV57 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 17:57:59 -0400
To: Brice Goglin <brice@myri.com>
In-Reply-To: <44625CD2.8040100@myri.com> (Brice Goglin's message of "Wed, 10 May 2006 23:36:18 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A few quick obvious comments:

 > +#ifdef MYRI10GE_MCP
 > +typedef signed char          int8_t;
 > +typedef signed short        int16_t;
 > +typedef signed int          int32_t;
 > +typedef signed long long    int64_t;
 > +typedef unsigned char       uint8_t;
 > +typedef unsigned short     uint16_t;
 > +typedef unsigned int       uint32_t;
 > +typedef unsigned long long uint64_t;
 > +#endif

What's this doing?  If you must use uintXX_t types the kernel already
has them.  Although it would be nicer to use u8, u16, etc.

 > +/* 8 Bytes */
 > +typedef struct
 > +{
 > +  uint32_t high;
 > +  uint32_t low;
 > +} mcp_dma_addr_t;

All of these typedefs are unnecessary.  In the kernel it's strongly
preferred to just do

struct mcp_dma_addr {
	u32 high;
        u32 low;
};

and then use "struct mcp_dma_addr" instead of "mcp_dma_addr_t".

Similarly for enums.  Just use "enum whatever" instead of "whatever_t".

BTW, indentation is busted in these headers too (two spaces instead of a tab).

 - R.
