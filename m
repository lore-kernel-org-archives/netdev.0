From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Move interface across network namespaces
Date: Thu, 11 Aug 2011 00:13:07 -0700
Message-ID: <m1r54s8lq4.fsf@fess.ebiederm.org>
References: <CAChaegkomwjL0X7HnfLi1XH26jDKOL6fCgjfms67cjjU4gRXPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Renato Westphal <renatowestphal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:53015 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754282Ab1HKHNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 03:13:11 -0400
In-Reply-To: <CAChaegkomwjL0X7HnfLi1XH26jDKOL6fCgjfms67cjjU4gRXPg@mail.gmail.com>
	(Renato Westphal's message of "Wed, 10 Aug 2011 21:31:39 -0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Renato Westphal <renatowestphal@gmail.com> writes:

> Hello,
>
> I have two questions regarding the process of moving a network
> interface across different network namespaces:
>
> * When I move an interface, all the virtual interfaces attached to it
> are deleted. Is there any reason for such odd behavior? I would like
> to move some network interfaces and keep the attached vlans untouched.

The defined semantics are that a network device is unregistered from
the networking stack in one network namespace and then registered
with the networking stack in another.  It is an unfortunate fact
that when vlan devices see their underlying device being unregistered
they decide to delete themselves.

A different vlan implementation might be able to have different
properties but I can't think of any obvious solution other than
don't do move the device that you have your vlans on top of.

> * The target network namespace sends a RTM_NEWLINK netlink message
> when an interface is moved to it. In the other hand, the source
> network namespace doesn't sends a RTM_DELLINK message when an
> interface is moved from it. This is very annoying because user space
> applications (such as zebra) can't detect some interface moving
> operations and then get into an inconsistent state. Anyone knows if
> there's a workaround for this?

Not getting RTM_DELLINK is a bug.  The device registration and
unregistration code has changed since dev_change_net_namespace was
written and apparently one of the changes failed to update
dev_change_net_namespace.

Eric

