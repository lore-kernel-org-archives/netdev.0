From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH] bonding: Fix corrupted queue_mapping
Date: Fri, 08 Jun 2012 09:16:15 -0700
Message-ID: <4FD2254F.1090900@intel.com>
References: <1339135057.6001.20.camel@edumazet-glaptop>  <20120607.230216.2014005732863772019.davem@davemloft.net>  <1339135881.6001.25.camel@edumazet-glaptop>  <20120607.231501.463746858434969001.davem@davemloft.net>  <1339138040.6001.39.camel@edumazet-glaptop>  <1339140238.6001.42.camel@edumazet-glaptop>  <CA+mtBx9xpy6Ly=3kiBc+sdHqFfsO5KRK8O=VAXTb3rofAgm2ow@mail.gmail.com> <1339168272.6001.116.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:57717 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761221Ab2FHQQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2012 12:16:16 -0400
In-Reply-To: <1339168272.6001.116.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/8/2012 8:11 AM, Eric Dumazet wrote:
> On Fri, 2012-06-08 at 08:04 -0700, Tom Herbert wrote:
>
>> Maybe the fundamental issue is that the queue mappings only allow for
>> one level of multi queue device.  It might be better if bonding didn't
>> have one and dev_pick_tx did the right thin (use xps on bonding
>> maybe).
>
> bonding misuses multiqueue infrastructure to divert frames on selected
> slaves, or maybe I am wrong.
>

This is right see bond_slave_override() here the slaves queue_ids
are mapped to skb->queue_mapping via this TX_QUEUE_OVERRIDE param.
