From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] mpls: allow TTL propagation to/from IP packets to be configured
Date: Fri, 03 Feb 2017 16:21:39 +1300
Message-ID: <87bmukhscc.fsf@xmission.com>
References: <1485808575-16852-1-git-send-email-rshearma@brocade.com>
        <878tpst75o.fsf@xmission.com>
        <9aff4996-3e8e-66e3-c806-80b3947fcf08@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        roopa <roopa@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:53993 "EHLO
        out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752009AbdBCD0L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 22:26:11 -0500
In-Reply-To: <9aff4996-3e8e-66e3-c806-80b3947fcf08@brocade.com> (Robert
        Shearman's message of "Tue, 31 Jan 2017 11:59:24 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> On 31/01/17 00:17, Eric W. Biederman wrote:
>> Robert Shearman <rshearma@brocade.com> writes:
>>
>>> It is sometimes desirable to present an MPLS transport network as a
>>> single hop to traffic transiting it because it prevents confusion when
>>> diagnosing failures. An example of where confusion can be generated is
>>> when addresses used in the provider network overlap with addresses in
>>> the overlay network and the addresses get exposed through ICMP errors
>>> generated as packets transit the provider network.
>>>
>>> Therefore, provide the ability to control whether the TTL value from
>>> an MPLS packet is propagated to an IPv4/IPv6 packet when the last
>>> label is popped through the addition of a new per-namespace sysctl:
>>> "net.mpls.ip_ttl_propagate" which defaults to enabled.
>>>
>>> Use the same sysctl to control whether the TTL is propagated from IP
>>> packets into the MPLS header. If the TTL isn't propagated then a
>>> default TTL value is used which can be configured via a new sysctl:
>>> "net.mpls.default_ttl".
>>
>> Instead of having a global sysctl can we please have a different way
>> to configure the ingress/egress?
>>
>> My general memory is that this makes sense for a slightly different
>> tunnel type.   Making it a per mpls tunnel property instead of global
>> property feels like it should be much more maintainable.
>
> RFC 3443 that David Ahern referenced does indeed infer that this
> should be a per-LSP property. However, it says:
>
>>    We also note here that signaling the LSP type (Pipe, Short Pipe or
>>    Uniform Model) is out of the scope of this document, and that is also
>>    not addressed in the current versions of the label distribution
>>    protocols, e.g. LDP [MPLS-LDP] and RSVP-TE [MPLS-RSVP].  Currently,
>>    the LSP type is configured by the network operator manually by means
>>    of either a command line or network management interface.
>
> AIUI, the situation of label distribution protocols not signaling this
> property hasn't changed from when this RFC has written, which limits
> the usefulness of a per-LSP property, and perhaps also indicates a
> lack of desire from users of this.
>
> Do you still feel it's worth implementing on a per-LSP basis? If so,
> any opinion on how it should be done for the pop case? Either a new
> per-path RTA attribute can be added, e.g. RTA_TTL_PROPAGATE, or a new
> rtnh flag could be added, e.g. RTNH_F_TTL_PROPAGATE.

My brain is mostly elswhere right now so I don't have an implementation
on how it should be implemented.   However Linux fundamentally gets used
interesting ways, and if we don't implement the option as per mpls exit
now someone will come along and need to do the work later.

Perhaps it will only be used with hard coded static configurations, and
it is fundamentally a per tunnel property.

It will be less work to maintain, and the code will run faster in the
long run if we don't have two code paths to maintain.

Eric
