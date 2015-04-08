From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next v3 3/4] mpls: Per-device enabling of packet input
Date: Wed, 08 Apr 2015 09:44:31 -0500
Message-ID: <877ftmel2o.fsf@x220.int.ebiederm.org>
References: <1426866170-28739-1-git-send-email-rshearma@brocade.com>
	<1427739356-28113-1-git-send-email-rshearma@brocade.com>
	<1427739356-28113-4-git-send-email-rshearma@brocade.com>
	<877ftnkh1u.fsf@x220.int.ebiederm.org> <55253B61.3000809@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "davem\@davemloft.net" <davem@davemloft.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:55096 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754148AbbDHOsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 10:48:36 -0400
In-Reply-To: <55253B61.3000809@brocade.com> (Robert Shearman's message of
	"Wed, 8 Apr 2015 15:29:53 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> On 07/04/15 18:02, Eric W. Biederman wrote:
>> Robert Shearman <rshearma@brocade.com> writes:
>>
>>> An MPLS network is a single trust domain where the edges must be in
>>> control of what labels make their way into the core. The simplest way
>>> of ensuring for the edge device to always impose the labels, and not
>>> allow forward labeled traffic from untrusted neighbours. This is
>>> achieved by allowing a per-device configuration of whether MPLS
>>> traffic input from that interface should be processed or not.
>>>
>>> To be secure by default, MPLS is now intially disabled on all
>>> interfaces (except the loopback) until explicitly enabled and no
>>> global option is provided to change the default. Whilst this differs
>>> from other protocols (e.g. IPv6), network operators are used to
>>> explicitly enabling MPLS forwarding on interfaces, and with the number
>>> of links to the MPLS core typically fairly low this doesn't present
>>> too much of a burden on operators.
>>
>> This really could use breaking up into two patches.
>>
>> 1 patch that implements mpls_add_dev,
>> and a second patch that uses the struct mpls_dev to implement
>> the input bit.
>
> Sure, I'll do that.
>
>> As it stands we are currently allowing mpls attributes on devices that
>> we do not support the transport of mpls over.  And simply not being able
>> to find an mpls_dev would be a faster was to discard packets on those
>> devices.
>
> Note that this will change the semantics, since currently we allow MPLS packets
> to be input on device types other than ethernet and loopback, whereas with this
> change they won't by default and won't be able to enable it. If that's what you
> intended and it's desirable then I'll proceed with that.

Yes.  For device types where we haven't figured out how to support MPLS
yet we should just have reception of MPLS packets disabled.

>> Naming the attribute input clears up all of the semantic issues that I
>> had with the previous version of this patch.
>
> Thanks for confirming that.

Eric
