From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netfront: clean up code in xennet_release_rx_bufs
Date: Wed, 15 Jan 2014 22:15:23 +0800
Message-ID: <52D697FB.3000304@oracle.com>
References: <1389307718-2845-1-git-send-email-Annie.li@oracle.com> <20140115100743.GG5698@zion.uk.xensource.com> <52D66ADF.9070401@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, netdev@vger.kernel.org,
	ian.campbell@citrix.com, xen-devel@lists.xen.org
To: Andrew Bennieston <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:36008 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089AbaAOOPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 09:15:37 -0500
In-Reply-To: <52D66ADF.9070401@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2014-1-15 19:02, Andrew Bennieston wrote:
> On 15/01/14 10:07, Wei Liu wrote:
>> On Fri, Jan 10, 2014 at 06:48:38AM +0800, Annie Li wrote:
>>> Current netfront only grants pages for grant copy, not for grant 
>>> transfer, so
>>> remove corresponding transfer code and add receiving copy code in
>>> xennet_release_rx_bufs.
>>>
>>
>> This path seldom gets call -- not that many people unload xen-netfront
>> driver. If Annie has tested this patch and it works as expected I think
>> it's fine.
>>
> In XenServer we have seen a number of cases where unplugging and 
> replugging VIFs results in leakage of grant references, eventually 
> leading to a case where you cannot plug a VIF (after ~ 400 such 
> cycles)...
>
> It's worth pointing out, as far as this patch is concerned, that 
> gnttab_end_foreign_access() can fail, 

Just like what Wei mentioned, it is gnttab_end_foreign_access_ref here, 
right?

> which is not taken into account here.

Good point, gnttab_end_foreign_access_ref fails for grant which is in use.

Thanks
Annie
>
> Andrew.
>
>> I'm not netfront maintainer but I'm happy to add
>> Acked-by: Wei Liu <wei.liu2@citrix.com>
>> if Annie confirms she's tested this patch.
>>
>> Wei.
>>
>> _______________________________________________
>> Xen-devel mailing list
>> Xen-devel@lists.xen.org
>> http://lists.xen.org/xen-devel
>>
>
