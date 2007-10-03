From: Dmitry Baryshkov <dbaryshkov@gmail.com>
Subject: Re: [PATCH] Fallback to ipv4 if we try to add join IPv4 multicast
 group via   ipv4-mapped address.
Date: Wed, 03 Oct 2007 17:26:35 +0400
Message-ID: <4703988B.3010904@gmail.com>
References: <1191319182.28331.6.camel@doriath.ww600.siemens.net> <OFDC1D2E6E.2DCF75EA-ON88257368.0053513A-88257368.005586DC@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:51127 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754631AbXJCNsH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2007 09:48:07 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1Id4X8-0003VB-LJ
	for netdev@vger.kernel.org; Wed, 03 Oct 2007 13:45:02 +0000
Received: from iap-pxy-mow1.siemens.ru ([212.248.25.26])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 03 Oct 2007 13:45:02 +0000
Received: from dbaryshkov by iap-pxy-mow1.siemens.ru with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 03 Oct 2007 13:45:02 +0000
In-Reply-To: <OFDC1D2E6E.2DCF75EA-ON88257368.0053513A-88257368.005586DC@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

David Stevens wrote:
> Dmitry,
>         Good catch; a couple comments:

Thank you for the response.

> 
>>     struct ipv6_pinfo *np = inet6_sk(sk);
>>     int err;
>> +   int addr_type = ipv6_addr_type(addr);
>> +
>> +   if (addr_type == IPV6_ADDR_MAPPED) {
>> +      __be32 v4addr = addr->s6_addr32[3];
>> +      struct ip_mreqn mreq;
>> +      mreq.imr_multiaddr.s_addr = v4addr;
>> +      mreq.imr_address.s_addr = INADDR_ANY;
>> +      mreq.imr_ifindex = ifindex;
>> +
>> +      return ip_mc_join_group(sk, &mreq);
>> +   }
> 
>         ipv6_addr_type() returns a bitmask, so you should use:
> 
>         if (addr_type & IPV6_ADDR_MAPPED) {

I just c'n'pasted the code that checks for mapped addresses. In most 
cases it's just ==, not bitmask operation.

> 
> Also, you should have a blank line after the "mreq" declaration.

ok.

> 
> Ditto for both in ipv6_mc_sock_drop().


> I don't expect the multicast source filtering interface will
> behave well for mapped addresses, either. The mapped multicast
> address won't appear to be a multicast address (and return
> error there), and all the source filters would have to be
> v4mapped addresses and modify the v4 source filters for this
> to do as you expect. So, there's more to it (and it may be a
> bit messy) to support mapped multicast addresses fully. I'll
> think about that part some more.


Didn't have time to test it throughly. I've only checked that call 
succeeds and that all necessary igmp are sent. I hope, this weekend I'll 
have more time to check.

--
With best wishes
Dmitry Baryshkov

