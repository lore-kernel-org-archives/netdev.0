From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH 1/4] xen-netfront: remove unused variable
 `extra'
Date: Tue, 19 Mar 2013 17:53:32 +0800
Message-ID: <5148359C.8040906@oracle.com>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com> <1363602955-24790-2-git-send-email-wei.liu2@citrix.com> <1363606922.30193.21.camel@zakaz.uk.xensource.com> <1363608271.29093.196.camel@zion.uk.xensource.com> <1363608860.30193.39.camel@zakaz.uk.xensource.com> <5147CFD2.8040803@oracle.com> <291EDFCB1E9E224A99088639C4762022013F7D2D3543@LONPMAILBOX01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41486 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262Ab3CSJxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 05:53:10 -0400
In-Reply-To: <291EDFCB1E9E224A99088639C4762022013F7D2D3543@LONPMAILBOX01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-3-19 17:28, Paul Durrant wrote:
>> -----Original Message-----
>> From: xen-devel-bounces@lists.xen.org [mailto:xen-devel-
>> bounces@lists.xen.org] On Behalf Of annie li
>> Sent: 19 March 2013 02:39
>> To: Ian Campbell
>> Cc: netdev@vger.kernel.org; konrad.wilk@oracle.com; Wei Liu; xen-
>> devel@lists.xen.org
>> Subject: Re: [Xen-devel] [PATCH 1/4] xen-netfront: remove unused variable
>> `extra'
>>
>>
>> On 2013-3-18 20:14, Ian Campbell wrote:
>>> On Mon, 2013-03-18 at 12:04 +0000, Wei Liu wrote:
>>>> On Mon, 2013-03-18 at 11:42 +0000, Ian Campbell wrote:
>>>>> On Mon, 2013-03-18 at 10:35 +0000, Wei Liu wrote:
>>>>>
>>>>> I think a few more words are needed here since from the code you are
>>>>> removing it seems very much like gso is used for something. If you have
>>>>> a proof that the "extra = gso" case is never hit then please explain it.
>>>>> Perhaps a reference to the removal of the last user?
>>>>>
>>>>> Or maybe it is the case that it should be used and the bug is that it
>>>>> isn't?
>>>>>
>>>> Looks like the latter one. 'extra' field should  be used to get hold of
>>>> the last extra info in the ring. ;-)
>>>>
>>>> But, the only extra info in upstream kernel is
>> XEN_NETIF_EXTRA_TYPE_GSO,
>>>> so there's really no other extra info in the ring at that point. Could
>>>> it be possible that it is something from classic Xen kernel?
>>> The classic kernel netfront has exactly the same code it seems and
>>> netif_extra_type_gso is the only one I've ever heard of.
>>>
>>> Maybe this extra thing is just redundant unless/until a second extra
>>> comes along.
>> In our windows pv driver, we do not process this for GSO in tx path
>> either. Maybe we ignored processing for some special GSO?
>>
>> BTW, what is XEN_NETIF_EXTRA_FLAG_MORE actually for? Backend only
>> processes it in xen_netback_tx_build_gops, but netfront xmit path does
>> not really set this flag. I did process it in rx path of my windows pv
>> driver(linux netfront did that too), but it seems unnecessary since
>> netback does not set this flag at all.
>>
> The flag is there to denote the existence of an 'extra' segment in the packet. The 'extra' segment goes after the 1st segment and specifies metadata such as the GSO type (TCPv4 is the only one at the moment but we'll need TCPv6 very shortly) and the MSS.

For TCPv4 GSO, it seems one extra info request(NETTXF_extra_info) is 
enough in my winpv driver, and I did not process the XEN_NETIF_EXTRA_MORE.
Do you create two extra info requests for bothTCPv4 and TCPv6 GSO like 
following?

  * [Request 2: netif_tx_extra]  (only if request 1 has NETTXF_extra_info)
  * [Request 3: netif_tx_extra]  (only if request 2 has XEN_NETIF_EXTRA_MORE)


> Extra segments are certainly not redundant; the Citrix Windows PV drivers send TSOs using them and handle LRO using them too.

About the LRO, upstream netback does not create any response with 
XEN_NETIF_EXTRA_MORE, so I assume your dom0 did such process?

Thanks
Annie
