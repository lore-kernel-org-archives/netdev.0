From: annie li <annie.li@oracle.com>
Subject: Re: [PATCH 6/8] netfront: multi-page ring support
Date: Thu, 28 Feb 2013 20:55:02 +0800
Message-ID: <512F53A6.4000401@oracle.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com> <1360944010-15336-7-git-send-email-wei.liu2@citrix.com> <512C5B96.10204@oracle.com> <1361882139.2109.52.camel@zion.uk.xensource.com> <512DB83A.6050503@oracle.com> <1361980154.2109.67.camel@zion.uk.xensource.com> <512EE8EF.30200@oracle.com> <20130228110237.GA23777@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39477 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265Ab3B1M4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 07:56:14 -0500
In-Reply-To: <20130228110237.GA23777@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-2-28 19:02, Wei Liu wrote:
> On Thu, Feb 28, 2013 at 05:19:43AM +0000, ANNIE LI wrote:
>> I checked the code in Konrad's tree and am thinking this overlap issue
>> you mentioned existing in original netback(without multi-ring) and newer
>> netfront. Original netback does not support multi-ring, and your newer
>> netfront before this bug fix used "#define TX_MAX_TARGET
>> XENNET_MAX_TX_RING_SIZE" directly. So that would cause overlap when
>> netfront allocating rx skbs.
>> "#define TX_MAX_TARGET min_t(int, NET_TX_RING_SIZE(1), 256)" limits the
>> netfront to single ring, it fixed the overlap issue, but not enough.
>>
> Yes. I just saw a bug report from Xen-user list yesterday for the same
> issue in original netback (1 page ring), so the overlap issue is not
> introduced by multi-page ring implementation. If your team also sees that
> issue, do you have patch to fix that?

No. We thought your patch fixed it, and I did not check it further at 
that time.
Are you sure they are same? What is the thread title in Xen-user?
The overlap issue here exists in netfront when netfront allocates skb 
greedily. In Konrad's tree merged with your patch, netfront with 
"#define TX_MAX_TARGET XENNET_MAX_TX_RING_SIZE" should hit this overlap 
issue when it runs with single ring netback.

Thanks
Annie
