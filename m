From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] net: l3mdev: Add master device lookup by
 index
Date: Mon, 23 Nov 2015 11:28:20 -0700
Message-ID: <56535AC4.7040105@cumulusnetworks.com>
References: <5651FBB8.6030008@cumulusnetworks.com>
 <20151122.131715.1858345389016284808.davem@davemloft.net>
 <56528FBC.6040205@cumulusnetworks.com>
 <20151122.233546.578035475304956705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35098 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbbKWS2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 13:28:24 -0500
Received: by pacej9 with SMTP id ej9so198622020pac.2
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 10:28:23 -0800 (PST)
In-Reply-To: <20151122.233546.578035475304956705.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/15 9:35 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Sun, 22 Nov 2015 21:02:04 -0700
>
>> I am confused by that response given that sk_bound_dev_if is one of
>> the key principals for the VRF implementation. Applications wanting to
>> communicate over interfaces in a VRF have to set sk_bound_dev_if.
>
> Yes, they have to set it explicitly.
>
> You are setting it for them in response to the connection
> creation, and that's what I object to.
>

The intent is to not require having N-listen sockets/threads/tasks to 
support N-vrfs for scalability reasons. Having a special DEVICE_ANY 
index adds complexity to socket lookups, so I dropped that idea long 
ago. Would guarding this behavior by a sysctl be acceptable?
