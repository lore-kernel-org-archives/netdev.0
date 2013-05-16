From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] vxlan: Update vxlan fdb 'used' field after each usage.
Date: Thu, 16 May 2013 15:22:44 -0700
Message-ID: <1368742964.14093.19.camel@sridhar.usor.ibm.com>
References: <1368723943.14093.4.camel@sridhar.usor.ibm.com>
	 <20130516.150019.1779890463663876284.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, dlstevens@us.ibm.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:42031 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754484Ab3EPWXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 18:23:03 -0400
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sri@us.ibm.com>;
	Thu, 16 May 2013 16:22:57 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 03AF73E4005B
	for <netdev@vger.kernel.org>; Thu, 16 May 2013 16:22:32 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4GMMm15358784
	for <netdev@vger.kernel.org>; Thu, 16 May 2013 16:22:48 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4GMPl5g004981
	for <netdev@vger.kernel.org>; Thu, 16 May 2013 16:25:48 -0600
In-Reply-To: <20130516.150019.1779890463663876284.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-16 at 15:00 -0700, David Miller wrote:
> From: Sridhar Samudrala <sri@us.ibm.com>
> Date: Thu, 16 May 2013 10:05:43 -0700
> 
> > Fix some instances where vxlan fdb 'used' field is not updated after the entry 
> > is used.
> > 
> > Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> 
> Please just put the ->used update into vxlan_find_mac().

I thought of doing it that way, but i found that there is a call
to vxlan_find_mac() in vxlan_fdb_create() where the fdb entry
gets updated, but it not really used.

Also in other cases, the fdb entry may not be used even if
vxlan_find_mac() returns an entry because of other conditions.

I guess it depends on how we define the 'used' field.

Thanks
Sridhar
