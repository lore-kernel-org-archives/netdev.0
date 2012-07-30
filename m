From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/2] net: Allow to create links with given ifindex
Date: Mon, 30 Jul 2012 03:56:47 -0700
Message-ID: <87fw89h5zk.fsf@xmission.com>
References: <50160EEF.6050406@parallels.com> <87pq7dh6b2.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:57587 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668Ab2G3K4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 06:56:53 -0400
In-Reply-To: <87pq7dh6b2.fsf@xmission.com> (Eric W. Biederman's message of
	"Mon, 30 Jul 2012 03:49:53 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ebiederm@xmission.com (Eric W. Biederman) writes:

> Pavel Emelyanov <xemul@parallels.com> writes:
>
>> Currently the RTM_NEWLINK results in -EOPNOTSUPP if the ifinfomsg->ifi_index
>> is not zero. I propose to allow requesting ifindices on link creation. This
>> is required by the checkpoint-restore to correctly restore a net namespace
>> (i.e. -- a container). The question what to do with pre-created devices such
>> as lo or sit fbdev is open, but for manually created devices this can be 
>> solved by this patch.
>
> Have you walked through and found the locations where we still rely on
> ifindex being globally unique?
>
> Last time I was working in this area there were serveral places where
> things were indexed by just the interface index.

If it is really safe to make ifindex per network namespace at this
point you can make dev_new_ifindex have a per network namespace base
counter, and that will fix your problems with the loopback device.

Unless you have done the work to root out the last of dependencies on
ifindex being globally unique I think you will run into some operational
problems.

Eric
