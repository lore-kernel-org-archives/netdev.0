From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC net-next 07/14] Fix intel/ixgbe
Date: Wed, 20 Jun 2012 08:30:48 -0700
Message-ID: <4FE1ECA8.1060201@intel.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>  <1340118848-30978-8-git-send-email-yuvalmin@broadcom.com>  <4FE0A0CD.5050909@intel.com> <1340182514.4604.843.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Yuval Mintz <yuvalmin@broadcom.com>, netdev@vger.kernel.org,
	davem@davemloft.net, eilong@broadcom.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:12750 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752654Ab2FTPau (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 11:30:50 -0400
In-Reply-To: <1340182514.4604.843.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/20/2012 1:55 AM, Eric Dumazet wrote:
> On Tue, 2012-06-19 at 08:54 -0700, Alexander Duyck wrote:
>
>> This patch doesn't limit the number of queues.  It is limiting the
>> number of interrupts.  The two are not directly related as we can
>> support multiple queues per interrupt.
>>
>> Also this change assumes we are only using receive side scaling.  We
>> have other features such as DCB, FCoE, and Flow Director which require
>> additional queues.
>>
>
> Yet, it would be good if ixgbe doesnt allocate 36 queues on a 4 cpu
> machine.
>
> "tc -s class show dev eth0" output is full of not used classes.
>
>
>

We do this for the DCB/FCoE/RSS/Flow Director case where we want to
use multiple queues per traffic class (802.1Qaz). As it is now we
have to set the max queues at alloc_etherdev_mq() time so we use a
max of
	(num_cpu * max traffic classes) + num_cpu

The last num_cpu is in error and I have a patch in JeffK's tree to
remove this. In many cases it seems excessive but sometimes it is
helpful.

.John
