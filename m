From: annie li <annie.li@oracle.com>
Subject: Re: [PATCH 1/4] xen-netfront: remove unused variable `extra'
Date: Tue, 19 Mar 2013 10:39:14 +0800
Message-ID: <5147CFD2.8040803@oracle.com>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>  <1363602955-24790-2-git-send-email-wei.liu2@citrix.com>  <1363606922.30193.21.camel@zakaz.uk.xensource.com>  <1363608271.29093.196.camel@zion.uk.xensource.com> <1363608860.30193.39.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50187 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756153Ab3CSCim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 22:38:42 -0400
In-Reply-To: <1363608860.30193.39.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-3-18 20:14, Ian Campbell wrote:
> On Mon, 2013-03-18 at 12:04 +0000, Wei Liu wrote:
>> On Mon, 2013-03-18 at 11:42 +0000, Ian Campbell wrote:
>>> On Mon, 2013-03-18 at 10:35 +0000, Wei Liu wrote:
>>>
>>> I think a few more words are needed here since from the code you are
>>> removing it seems very much like gso is used for something. If you have
>>> a proof that the "extra = gso" case is never hit then please explain it.
>>> Perhaps a reference to the removal of the last user?
>>>
>>> Or maybe it is the case that it should be used and the bug is that it
>>> isn't?
>>>
>> Looks like the latter one. 'extra' field should  be used to get hold of
>> the last extra info in the ring. ;-)
>>
>> But, the only extra info in upstream kernel is XEN_NETIF_EXTRA_TYPE_GSO,
>> so there's really no other extra info in the ring at that point. Could
>> it be possible that it is something from classic Xen kernel?
> The classic kernel netfront has exactly the same code it seems and
> netif_extra_type_gso is the only one I've ever heard of.
>
> Maybe this extra thing is just redundant unless/until a second extra
> comes along.

In our windows pv driver, we do not process this for GSO in tx path 
either. Maybe we ignored processing for some special GSO?

BTW, what is XEN_NETIF_EXTRA_FLAG_MORE actually for? Backend only 
processes it in xen_netback_tx_build_gops, but netfront xmit path does 
not really set this flag. I did process it in rx path of my windows pv 
driver(linux netfront did that too), but it seems unnecessary since 
netback does not set this flag at all.

Thanks
Annie
