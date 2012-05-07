From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] 9p: disconnect channel when PCI device is removed
Date: Mon, 07 May 2012 12:44:03 +0530
Message-ID: <87pqagzcn8.fsf@skywalker.in.ibm.com>
References: <1334353716-19483-1-git-send-email-levinsasha928@gmail.com> <87397chebf.fsf@rustcorp.com.au>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davej@redhat.com, Sasha Levin <levinsasha928@gmail.com>
To: Rusty Russell <rusty@rustcorp.com.au>,
	Sasha Levin <levinsasha928@gmail.com>, davem@davemloft.net,
	ericvh@gmail.com, jvrao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:60777 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755079Ab2EGHPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2012 03:15:31 -0400
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 7 May 2012 08:03:44 +1000
In-Reply-To: <87397chebf.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell <rusty@rustcorp.com.au> writes:

> On Fri, 13 Apr 2012 17:48:36 -0400, Sasha Levin <levinsasha928@gmail.com> wrote:
>> When a virtio_9p pci device is being removed, we should close down any
>> active channels and free up resources, we're not supposed to BUG() if there's
>> still an open channel since it's a valid case when removing the PCI device.
>> 
>> Otherwise, removing the PCI device with an open channel would cause the
>> following BUG():
>
> (Damn changed notmuch.el bindings!  Previous reply went only to Sasha).
>
> Applied thanks,
> Rusty.

I am not sure whether the patch is sufficient, p9_virtio_remove does a
kfree(chan) and since we are not doing anything at the file system
level, we would still allow new 9p client request. That means
p9_virtio_request would be dereferencing a freed memory.

-aneesh
