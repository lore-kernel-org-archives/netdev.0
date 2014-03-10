From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [PATCH net] Xen-netback: Fix issue caused by using
 gso_type wrongly
Date: Mon, 10 Mar 2014 13:29:08 +0000
Message-ID: <531DBE24.8020403@citrix.com>
References: <1394437454-2402-1-git-send-email-Annie.li@oracle.com> <9AAE0902D5BC7E449B7C8E4E778ABCD0279FBD@AMSPEX01CL01.citrite.net> <531DBCEC.4070201@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: annie li <annie.li@oracle.com>,
	Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:4812 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752628AbaCJN3L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Mar 2014 09:29:11 -0400
In-Reply-To: <531DBCEC.4070201@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/14 13:23, annie li wrote:
> On 2014/3/10 17:51, Paul Durrant wrote:
>>> @@ -299,12 +299,12 @@ static void xenvif_gop_frag_copy(struct xenvif
>>> *vif,
>>> struct sk_buff *skb,
>>>           }
>>>
>>>           /* Leave a gap for the GSO descriptor. */
>>> -        if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
>>> -            gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
>>> -        else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
>>> -            gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
>>> -        else
>>> -            gso_type = XEN_NETIF_GSO_TYPE_NONE;
>>> +        if (skb_shinfo(skb)->gso_size) {
>> You should probably use skb_is_gso(skb) for your test.
>
> skb_is_gso does the same thing, skb_iso_gso and
> skb_shinfo(skb)->gso_size coexist. But I can change the code as you
> suggested if you like, will post a v2 patch for this.

It's always better to use core functions which codify these rules. Also, 
from the reader's point of view, it's more obvious to see skb_is_gso, 
than checking gso_size.
