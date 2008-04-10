From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH]: net/bonding: Enable to change device type before enslaving
Date: Thu, 10 Apr 2008 13:48:24 -0700
Message-ID: <21771.1207860504@death>
References: <47FE2DBF.7080803@voltaire.com>
Cc: netdev <netdev@vger.kernel.org>, Olga Stern <olgas@voltaire.com>,
	Or Gerlitz <ogerlitz@voltaire.com>
To: monis@voltaire.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:45701 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753404AbYDJUs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 16:48:27 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3AKmQIJ003115
	for <netdev@vger.kernel.org>; Thu, 10 Apr 2008 16:48:26 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3AKmQiM189818
	for <netdev@vger.kernel.org>; Thu, 10 Apr 2008 14:48:26 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3AKmPA2029961
	for <netdev@vger.kernel.org>; Thu, 10 Apr 2008 14:48:25 -0600
In-reply-to: <47FE2DBF.7080803@voltaire.com> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moni Shoua <monis@voltaire.com> wrote:

>
>The bonding network device is being created  with device type ARPHDR_ETHER.
>Although the device type changes with first slave we want to be able to change
>it when it has zero slaves. The reason is to make the kernel choose the right
>function for multicast address translation (ib_xxx_mc_map) which is determined by
>device type even when no slaves are enslaved. If not so, the kernel picks a wrong
>translation function and wrong HW addresses will be passed to slaves when the
>bonding device tries to set their multicast lists.

	Does this mean that the automatic selection on first enslavement
is no longer needed, and all setting of the type for IB devices must
occur prior to first enslavement?

	Or is this more of a special case for some devices, and the
automatic selection is still correct for most cases?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
