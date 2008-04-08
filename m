From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH net-2.6.26 1/2] Shrink size of net_device by filling	alignment
 holes in it.
Date: Tue, 08 Apr 2008 12:41:18 +0400
Message-ID: <47FB2FAE.3080008@openvz.org>
References: <47FA4ADE.1020308@openvz.org> <47FA5426.10704@cosmosbay.com> <47FA5717.4070901@cosmosbay.com> <20080407174745.GE15681@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:35743 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751149AbYDHISO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 04:18:14 -0400
In-Reply-To: <20080407174745.GE15681@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, here are the results (summary):

i386, no patch, L1_CACHE_SHIFT=6:
        /* size: 1024, cachelines: 16 */
        /* sum members: 897, holes: 5, sum holes: 115 */
        /* padding: 12 */

i386, no patch, L1_CACHE_SHIFT=7:
        /* size: 1280, cachelines: 20 */
        /* sum members: 897, holes: 5, sum holes: 307 */
        /* padding: 76 */

i386, with patch, L1_CACHE_SHIFT=6:
        /* size: 960, cachelines: 15 */
        /* sum members: 897, holes: 4, sum holes: 47 */
        /* padding: 16 */

i386, with patch, L1_CACHE_SHIFT=7:
        /* size: 1024, cachelines: 16 */
        /* sum members: 897, holes: 4, sum holes: 111 */
        /* padding: 16 */

x86_64, no patch, L1_CACHE_SHIFT=7:
        /* size: 1792, cachelines: 28 */
        /* sum members: 1589, holes: 13, sum holes: 155 */
        /* padding: 48 */
        /* paddings: 1, sum paddings: 4 */

x86_64, with patch, L1_CACHE_SHIFT=7:
        /* size: 1920, cachelines: 30 */
        /* sum members: 1589, holes: 13, sum holes: 275 */
        /* padding: 56 */
        /* paddings: 1, sum paddings: 4 */

The +128 bytes on x86_64 is due to enlarged hole before
the refcnt field :(

So, on the i386 the structure shrinks, but on x86_64 - grows, but
on i386 it can be allocated from a twice smaller cache, while on
x86_64 nothing changes - it still fits the size-2048.

BTW, L1_CACHE_SHIFT=7 is set by default for distributions such as
rhel5, suse10 and fedora8...

So, does it worth trying to push them to Dave? :)

Thanks,
Pavel
