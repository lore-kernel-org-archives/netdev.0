From: Bart Van Assche <bvanassche@acm.org>
Subject: Re: [PATCH v4 0/10] skb paged fragment destructors
Date: Wed, 11 Apr 2012 10:02:07 +0000
Message-ID: <4F85569F.1070806@acm.org>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>  <4F8455EE.8010709@acm.org> <1334073004.5394.59.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"Wei Liu (Intern)" <wei.liu2@citrix.com>,
	David VomLehn <dvomlehn@cisco.com>,
	xen-devel <xen-devel@lists.xen.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay03ant.iops.be ([212.53.5.218]:43932 "EHLO
	relay03ant.iops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754964Ab2DKKCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 06:02:17 -0400
In-Reply-To: <1334073004.5394.59.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/12 15:50, Ian Campbell wrote:

> On Tue, 2012-04-10 at 16:46 +0100, Bart Van Assche wrote:
>> Great to see v4 of this patch series. But which kernel version has this
>> patch series been based on ? I've tried to apply this series on 3.4-rc2
> 
> It's based on net-next/master. Specifically commit de8856d2c11f.


Thanks, that information allowed me to apply the patch series and to
test it with kernel 3.4-rc2 and iSCSI target code. The test ran fine.

The failure to apply this patch series on 3.4-rc2 I had reported turned
out to be an easy to resolve merge conflict:

+ static int ceph_tcp_sendpage(struct socket *sock, struct page *page,
+ 		     int offset, size_t size, int more)
+ {
+ 	int flags = MSG_DONTWAIT | MSG_NOSIGNAL | (more ? MSG_MORE : MSG_EOR);
+ 	int ret;
+ 
 -	ret = kernel_sendpage(sock, page, offset, size, flags);
++	ret = kernel_sendpage(sock, page, NULL, offset, size, flags);
+ 	if (ret == -EAGAIN)
+ 		ret = 0;
+ 
+ 	return ret;
+ }
+ 

Bart.
