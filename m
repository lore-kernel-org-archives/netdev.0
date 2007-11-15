From: "Denis V. Lunev" <den@sw.ru>
Subject: Re: [PATCH 2/2] move unneeded data to initdata section
Date: Thu, 15 Nov 2007 17:42:04 +0300
Message-ID: <473C5ABC.5090204@sw.ru>
References: <20071107120100.GA10185@iris.sw.ru> <m1abpfy3xz.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Denis V. Lunev" <den@openvz.org>, davem@davemloft.net,
	containers@lists.osdl.org, netdev@vger.kernel.org, clg@fr.ibm.com,
	benjamin.thery@bull.net
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:51429 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756786AbXKOOiI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 09:38:08 -0500
In-Reply-To: <m1abpfy3xz.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> "Denis V. Lunev" <den@openvz.org> writes:
> 
>> This patch reverts Eric's commit 2b008b0a8e96b726c603c5e1a5a7a509b5f61e35
>>
>> It diets .text & .data section of the kernel if CONFIG_NET_NS is not set.
>> This is safe after list operations cleanup.
> 
> Ok.  This patch is technically safe because none of the touched
> code can live in a module and so we never touch the exit code path.
> 
> However in the general case and as a code idiom this __net_initdata
> on struct pernet_operations is fundamentally horribly broken.
> 
> Look at what happens if we use this idiom in module.  There
> is only one definition of __initdata ".init.data".  The module
> loader places all sections that begin with .init in a region of
> memory that will be discarded after module initialization.  

nothing is discarded after module load. Though, I can be wrong. Could
you point me to the exact place?

Regards,
	Den
