From: Wei Liu <liuw@liuw.name>
Subject: Re: [Xen-devel] [PATCH net-next V3 2/3] xen-netfront: split event
 channels support for Xen frontend driver
Date: Wed, 22 May 2013 21:38:20 +0100
Message-ID: <CAOsiSVUHqezpo4u+Go1pm4vm7Hots2gDUJ9YEzVK7_FPSc3zLA@mail.gmail.com>
References: <1369240487-18834-1-git-send-email-wei.liu2@citrix.com>
 <1369240487-18834-3-git-send-email-wei.liu2@citrix.com> <519D1D61.8030500@oracle.com>
 <CAOsiSVXptBRRA=m3HFnO7eQWjxN_wgfzAcvw+rPebOPH9mRjXg@mail.gmail.com> <519D2C02.7080500@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	David Vrabel <david.vrabel@citrix.com>,
	jbeulich <jbeulich@suse.com>
To: annie li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:52602 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389Ab3EVUiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 16:38:51 -0400
Received: by mail-wi0-f178.google.com with SMTP id hj6so382659wib.11
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 13:38:50 -0700 (PDT)
In-Reply-To: <519D2C02.7080500@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 22, 2013 at 9:35 PM, annie li <annie.li@oracle.com> wrote:
>
> On 2013-5-22 16:20, Wei Liu wrote:
>>
>> On Wed, May 22, 2013 at 8:32 PM, annie li <annie.li@oracle.com> wrote:
>>>
>>>
>>> Originally, netfront protects access to rx shared-ring with tx_lock, you
>>> remove this protection here. It is better to protect the ring access by a
>>> sperate rx_lock then.
>>>
>> TX ring and RX ring are separate rings. I don't think that comment / code
>> makes sense any more. My stress test confirms that.
>
>
> Yes, they are separate rings. Actually I am not sure why
> RING_HAS_UNCONSUMED_RESPONSES(&np->rx) is protected by any tx_lock
> originally. But for xennet_rx_interrupt, it is better to use rx_lock to
> protect RING_HAS_UNCONSUMED_RESPONSES(&np->rx).
>

This doesn't make sense to me either. Xen ring protocol is designed to
be lock-free.
And in netfront's case there is no concurrent access to the ring.


Wei.
