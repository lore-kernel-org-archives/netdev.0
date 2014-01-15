From: Andrew Bennieston <andrew.bennieston@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netfront: clean up code in xennet_release_rx_bufs
Date: Wed, 15 Jan 2014 11:02:55 +0000
Message-ID: <52D66ADF.9070401@citrix.com>
References: <1389307718-2845-1-git-send-email-Annie.li@oracle.com> <20140115100743.GG5698@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <ian.campbell@citrix.com>,
	<xen-devel@lists.xen.org>
To: Wei Liu <wei.liu2@citrix.com>, Annie Li <Annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:22416 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751004AbaAOLC4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 06:02:56 -0500
In-Reply-To: <20140115100743.GG5698@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/01/14 10:07, Wei Liu wrote:
> On Fri, Jan 10, 2014 at 06:48:38AM +0800, Annie Li wrote:
>> Current netfront only grants pages for grant copy, not for grant transfer, so
>> remove corresponding transfer code and add receiving copy code in
>> xennet_release_rx_bufs.
>>
>
> This path seldom gets call -- not that many people unload xen-netfront
> driver. If Annie has tested this patch and it works as expected I think
> it's fine.
>
In XenServer we have seen a number of cases where unplugging and 
replugging VIFs results in leakage of grant references, eventually 
leading to a case where you cannot plug a VIF (after ~ 400 such cycles)...

It's worth pointing out, as far as this patch is concerned, that 
gnttab_end_foreign_access() can fail, which is not taken into account here.

Andrew.

> I'm not netfront maintainer but I'm happy to add
> Acked-by: Wei Liu <wei.liu2@citrix.com>
> if Annie confirms she's tested this patch.
>
> Wei.
>
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
>
