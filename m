From: Ben Greear <greearb@candelatech.com>
Subject: ip_tables.h can't be used in C++ programs.
Date: Fri, 20 Aug 2010 11:54:31 -0700
Message-ID: <4C6ECF67.3040508@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53938 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752747Ab0HTSye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 14:54:34 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id o7KIsXo7006138
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 20 Aug 2010 11:54:34 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This method returns void* but is defined to return
a pointer to struct ipt_entry_target.

This will not compile under g++ (or, I'm unable to figure out
how to make it work w/out editing the header file).

Any reason this shouldn't be changed to:

  return (struct ipt_entry_target*)e + e->target_offset;


/* Helper functions */
static __inline__ struct ipt_entry_target *
ipt_get_target(struct ipt_entry *e)
{
         return (void *)e + e->target_offset;
}


IPv6 has similar issue....

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

