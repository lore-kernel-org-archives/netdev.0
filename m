From: Mukesh Hira <mhira@vmware.com>
Subject: ip xfrm transport mode forwarding policy
Date: Wed, 10 Feb 2016 19:30:38 +0000
Message-ID: <1455132654694.33181@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:35435 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751536AbcBJTaj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 14:30:39 -0500
Received: from sc9-mailhost3.vmware.com (sc9-mailhost3.vmware.com [10.113.161.73])
	by smtp-outbound-1.vmware.com (Postfix) with ESMTP id DE78A28BF5
	for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 11:30:37 -0800 (PST)
Received: from EX13-CAS-003.vmware.com (ex13-cas-003.vmware.com [10.113.191.53])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 99184405C6
	for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 11:30:38 -0800 (PST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

For a particular application, I am working on configuring a Linux host to receive IPSec traffic in transport mode on one interface, decrypt and forward the traffic in the clear on another interface.

I have configured a transport mode ip xfrm policy with dir fwd and corresponding ip xfrm state.

However, the IPSec traffic is being dropped with XfrmInTmplMismatch counter incrementing. Upon adding some debug statements and recompiling the kernel, I found that the IPSec transport mode traffic is taking the following path -

ip_forward calls __xfrm_policy_check - Here, skb->sp is null, hence a dummy sec_path gets passed to xfrm_policy_ok which returns -1 because the dummy sec_path has length 0.

How does one go about configuring IPSec transport mode forwarding? Is this supposed to work? Or does IPSec decryption followed by forwarding only work in tunnel mode?

Thanks,
Mukesh
