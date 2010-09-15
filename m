From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Wed, 15 Sep 2010 10:55:19 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D792B8C81532D@shsmsx502.ccr.corp.intel.com>
References: <1284410580.13351.10.camel@localhost.localdomain>
	 <1284410883.13351.14.camel@localhost.localdomain>
	 <20100913.201730.27805132.davem@davemloft.net>
	 <4C8F3C77.7010302@redhat.com>
	 <1284476719.13351.35.camel@localhost.localdomain>
	 <F2E9EB7348B8264F86B6AB8151CE2D792B8C8152A0@shsmsx502.ccr.corp.intel.com>
 <1284518452.13351.111.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Avi Kivity <avi@redhat.com>, David Miller <davem@davemloft.net>,
	"arnd@arndb.de" <arnd@arndb.de>, "mst@redhat.com" <mst@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64315 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752551Ab0IOCzt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 22:55:49 -0400
In-Reply-To: <1284518452.13351.111.camel@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Shirley Ma [mailto:mashirle@us.ibm.com]
>Sent: Wednesday, September 15, 2010 10:41 AM
>To: Xin, Xiaohui
>Cc: Avi Kivity; David Miller; arnd@arndb.de; mst@redhat.com; netdev@vger.kernel.org;
>kvm@vger.kernel.org; linux-kernel@vger.kernel.org
>Subject: RE: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host kernel
>
>On Wed, 2010-09-15 at 09:50 +0800, Xin, Xiaohui wrote:
>> I think what David said is what we have thought before in mp device.
>> Since we are not sure the exact time the tx buffer was wrote though
>> DMA operation.
>> But the deadline is when the tx buffer was freed. So we only notify
>> the vhost stuff
>> about the write when tx buffer freed. But the deadline is maybe too
>> late for performance.
>
>Have you tried it? If so what's the performance penalty you have seen by
>notifying vhost when tx buffer freed?
>

We did not try it before, as we cared RX side more.

>I am thinking to have a callback in skb destructor,
>vhost_add_used_and_signal gets updated when skb is actually freed, vhost
>vq & head need to be passed to the callback. This might requires vhost
>ring size is at least as big as the lower device driver.
>

That's almost the same what we have done except we use destructor_arg and
another callback..

>Thanks
>Shirley

