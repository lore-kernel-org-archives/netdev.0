From: Ben Greear <greearb@candelatech.com>
Subject: iproute2 question on flushing addresses
Date: Wed, 11 Aug 2010 10:01:23 -0700
Message-ID: <4C62D763.4080804@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:42829 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756234Ab0HKRBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 13:01:25 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id o7BH1Nn9017815
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 11 Aug 2010 10:01:23 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am trying to flush all secondary IPs before flushing primaries, because
otherwise it creates a flood of netlink messages as each primary is deleted
and a secondary takes over as primary (changing all routes for all other
secondaries).

I was thinking this command could work, but it does not appear to do
anything:

./local/sbin/ip addr flush dev rddVR17 secondary


While poking at the code..I saw this.  It seems to me that the check for IFA_F_SECONDARY
is reversed?

int print_addrinfo_primary(const struct sockaddr_nl *who, struct nlmsghdr *n,
			   void *arg)
{
	struct ifaddrmsg *ifa = NLMSG_DATA(n);

	if (!ifa->ifa_flags & IFA_F_SECONDARY)
		return 0;

	return print_addrinfo(who, n, arg);
}

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

