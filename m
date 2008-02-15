From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: tbench regression in 2.6.25-rc1
Date: Fri, 15 Feb 2008 09:52:01 +0800
Message-ID: <1203040321.3027.131.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:11510 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753513AbYBOBxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2008 20:53:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Comparing with kernel 2.6.24, tbench result has regression with
2.6.25-rc1.

1) On 2 quad-core processor stoakley: 4%.
2) On 4 quad-core processor tigerton: more than 30%.

bisect located below patch.

b4ce92775c2e7ff9cf79cca4e0a19c8c5fd6287b is first bad commit
commit b4ce92775c2e7ff9cf79cca4e0a19c8c5fd6287b
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Tue Nov 13 21:33:32 2007 -0800

    [IPV6]: Move nfheader_len into rt6_info
    
    The dst member nfheader_len is only used by IPv6.  It's also currently
    creating a rather ugly alignment hole in struct dst.  Therefore this patch
    moves it from there into struct rt6_info.


As tbench uses ipv4, so the patch's real impact on ipv4 is it deletes
nfheader_len in dst_entry. It might change cache line alignment.

To verify my finding, I just added nfheader_len back to dst_entry in 2.6.25-rc1
and reran tbench on the 2 machines. Performance could be recovered completely.

I started cpu_number*2 tbench processes. On my 16-core tigerton:
#./tbench_srv &
#./tbench 32 127.0.0.1

-yanmin


