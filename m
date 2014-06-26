From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 1/2] rtnetlink: allow to register ops without
 ops->setup set
Date: Thu, 26 Jun 2014 09:46:31 +0200
Message-ID: <20140626074631.GB3049@minipsycho.orion>
References: <1403715503-9059-1-git-send-email-jiri@resnulli.us>
 <20140625114500.7c09874e@haswell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, pshelar@nicira.com,
	cwang@twopensource.com, nicolas.dichtel@6wind.com,
	ebiederm@xmission.com, david@gibson.dropbear.id.au,
	sfeldma@cumulusnetworks.com, sucheta.chakraborty@qlogic.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:47832 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754646AbaFZHqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 03:46:35 -0400
Received: by mail-wi0-f176.google.com with SMTP id n3so487209wiv.3
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 00:46:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140625114500.7c09874e@haswell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jun 25, 2014 at 08:45:00PM CEST, stephen@networkplumber.org wrote:
>On Wed, 25 Jun 2014 18:58:22 +0200
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> So far, it is assumed that ops->setup is filled up. But there might be
>> case that ops might make sense even without ->setup. In that case,
>> forbid to newlink and dellink.
>> 
>> This allows to register simple rtnl link ops containing only ->kind.
>> That allows consistent way of passing device kind (either device-kind or
>> slave-kind) to userspace.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>Can't we fix these kind of devices to all create/delete. At least
>allow delete.
>

Well it is not that easy to create openvswitch device. To do that you
have to have info specified in vport_params (see ovs_vport_alloc).

Delete could be implemented. But looking at the code, it could be a bit
tricky. But would that make sense to implement del and don't implement
add? I think it's better to leave both out.
