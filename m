From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC PATCH v7 01/19] Add a new structure for skb buffer from
 external.
Date: Wed, 9 Jun 2010 16:29:28 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D791100848F17@shsmsx502.ccr.corp.intel.com>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com>
 <20100606161348.427822fb@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50423 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751370Ab0FII3r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 04:29:47 -0400
In-Reply-To: <20100606161348.427822fb@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Stephen Hemminger [mailto:shemminger@vyatta.com]
>Sent: Monday, June 07, 2010 7:14 AM
>To: Xin, Xiaohui
>Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org;
>mst@redhat.com; mingo@elte.hu; davem@davemloft.net; herbert@gondor.apana.org.au;
>jdike@linux.intel.com
>Subject: Re: [RFC PATCH v7 01/19] Add a new structure for skb buffer from external.
>
>Still not sure this is a good idea for a couple of reasons:
>
>1. We already have lots of special cases with skb's (frags and fraglist),
>   and skb's travel through a lot of different parts of the kernel.  So any
>   new change like this creates lots of exposed points for new bugs. Look
>   at cases like MD5 TCP and netfilter, and forwarding these SKB's to ipsec
>   and ppp and ...
>

Yes, I agree on your concern at some extent. But the skbs which use external pages in our cases have short travels which start from NIC driver and then forward to the guest immediately. It will not travel into host kernel stack or any filters which may avoid many problems you have mentioned here.

Another point is that we try to make the solution more generic to different NIC drivers, then many drivers may use the way without modifications.
  
>2. SKB's can have infinite lifetime in the kernel. If these buffers come from
>   a fixed size pool in an external device, they can easily all get tied up
>   if you have a slow listener. What happens then?

The pool is not fixed size, it's the size of usable buffers submitted by guest virtio-net driver. Guest virtio-net will check how much buffers are filled and do resubmit. What a slow listener mean? A slow NIC driver?

Thanks
Xiaohui
