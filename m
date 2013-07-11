From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net v2] gso: Update tunnel segmentation to support Tx
 checksum offload
Date: Thu, 11 Jul 2013 02:23:31 +0000 (UTC)
Message-ID: <krl4v3$o8d$1@ger.gmane.org>
References: <20130711000015.13134.17801.stgit@ahduyck-hc1.jf.intel.com>
 <1373503334.4600.27.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:45322 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754950Ab3GKCXy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jul 2013 22:23:54 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Ux6Xt-0003T1-En
	for netdev@vger.kernel.org; Thu, 11 Jul 2013 04:23:49 +0200
Received: from 116.53.101.57 ([116.53.101.57])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 04:23:49 +0200
Received: from xiyou.wangcong by 116.53.101.57 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 04:23:49 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Jul 2013 at 00:42 GMT, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-07-10 at 17:05 -0700, Alexander Duyck wrote:
>> This change makes it so that the GRE and VXLAN tunnels can make use of Tx
>> checksum offload support provided by some drivers via the hw_enc_features.
>> Without this fix enabling GSO means sacrificing Tx checksum offload and
>> this actually leads to a performance regression as shown below:
>> 
>>             Utilization
>>             Send
>> Throughput  local         GSO
>> 10^6bits/s  % S           state
>>   6276.51   8.39          enabled
>>   7123.52   8.42          disabled
>
> While testing your patch, I discovered TSO support is completely broken
> on GRE, using bnx2x testbed.
>

In my test, GRE works fine, but gretap not.
