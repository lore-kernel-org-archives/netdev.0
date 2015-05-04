From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH v3] bnx2x: Alloc 4k fragment for each rx ring buffer
 element
Date: Mon, 4 May 2015 19:58:06 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63D6F990@AVMB1.qlogic.org>
References: <553AD097.4020209@gmx.de>
	<87383jhxj9.fsf@dhcp-9-18-235-171.br.ibm.com>
	<B5657A6538887040AD3A81F1008BEC63D383CB@avmb3.qlogic.org>
	<20150430.160537.232956261880122754.davem@davemloft.net>,<874mnsxhnm.fsf_-_@dhcp-9-18-235-171.br.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "LinoSanfilippo@gmx.de" <LinoSanfilippo@gmx.de>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"cascardo@cascardo.eti.br" <cascardo@cascardo.eti.br>,
	"brking@linux.vnet.ibm.com" <brking@linux.vnet.ibm.com>
To: Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:64902 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751252AbbEDT6R convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 15:58:17 -0400
In-Reply-To: <874mnsxhnm.fsf_-_@dhcp-9-18-235-171.br.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A couple of not really important [ mostly style] issues -

>+       int             offset;
>+       int             frag_count;
u8 seems better, as we never really expect this to be negative.
[Could have claimed the same about the offset]

...

> +       if (!pool->page || pool->frag_count == 0) {
Why the "== 0" and not simply "!"?

 ...

> +       pool->frag_count -= 1;
Why not pool->frag_count-- ?

...

> +       /* Page was not fully fragmented.  Unmap unused space */
> +       if (pool->frag_count > 0) {
Again, why not (pool->frag_count) instead?

Regardless, I'll give it a more thorough review tomorrow.
[If those are all the "problems" we'll find with it, I don't think we'll
need to re-spin this once more; that is, unless Dave insists]

Thanks,
Yuval
