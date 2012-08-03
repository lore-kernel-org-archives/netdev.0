From: Dragos Ilie <dragos.ilie@gmail.com>
Subject: Re: Premature timeout for MLDv1 Host compatibility mode?
Date: Fri, 3 Aug 2012 10:54:09 +0200
Message-ID: <CAOLNa-e0DB7Vhvv8tcSdW_JSWavpmyNt0vFYHLymh_zDaqUiMw@mail.gmail.com>
References: <CAOLNa-dCpLG4XCarzbSb=ptu-KGVX_Fghv4Z_CDQ8HBF_n-rGQ@mail.gmail.com>
	<OFB6FB6105.8DE1252A-ON85257A4E.004637D4-85257A4E.00474EEF@us.ibm.com>
	<CAOLNa-dj1N-3Lo6Bu8X4H51gxBs4B2V0qWSDFQ-2qQzjEApJfw@mail.gmail.com>
	<OF675087EF.EDC93ADE-ON85257A4E.004B2D96-85257A4E.004CB6BE@us.ibm.com>
	<CAOLNa-cMkHaFxoWym-oVT6i7ZZ25tZPxaAEcwUuT1TB4kPGfag@mail.gmail.com>
	<OFA8EDA0BC.A9D42E39-ON85257A4E.004ECE32-85257A4E.004F3FC7@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:33111 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846Ab2HCIyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 04:54:10 -0400
In-Reply-To: <OFA8EDA0BC.A9D42E39-ON85257A4E.004ECE32-85257A4E.004F3FC7@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

I have been thinking about how to address your concerns about the
MLDv1-mode timeout. Unfortunately, I think by doing that we would stop
being compliant with RFC 3810 on the following points:

a) Section 5.1.9 states that the QQIC field is meant for other
multicast routers that are not the current querier. I "grep-ed" after
mld2q_qqic in the entire kernel source tree and it is not being used
at all. I take this as a sign that the field is not to be interpreted
by listeners. Of course, that does not mean we cannot use it, but see
b) below

b) Section 8.3.1 says that "if an MLDv1 router is present on the link,
the Querier MUST use the lowest  version of MLD present on the
network". Also, "if an MLDv1 router is present on the link, the system
administrator must explicitly configure all MLDv2 routers to act in
MLDv1 mode". It seems to me that these statements together preclude a
scenario with MLDv1 and MLDv2 routers mixed together on the same link,
unless all routers speak MLDv1.

The current implementation for MLDv1 compatibility mode works very
badly. The listeners fail most of the time to join the groups on the
MLDv1 server. I suggest  that my patch sent earlier this week is
pushed upstream, unless there are concerns that it will make things
worse than they are today. This will improve the behavior of MLDv2
listeners with MLDv1 routers and keep us compliant with the RFC. What
do you think?


On Thu, Aug 2, 2012 at 4:25 PM, David Stevens <dlstevens@us.ibm.com> wrote:
> netdev-owner@vger.kernel.org wrote on 08/02/2012 10:03:24 AM:
>
>> > The QQIC would come from v2 queries prior to the v1 query that
>> > triggered us to switch to v1. But, see below.
>>
>> How about the scenario where you have only MLDv1 queriers? There will
>> be no prior v2 query
>
>         Yes, this is why I suggested initializing it to the
> default of 125. If we actually saw v2 queries with different
> intervals, we'd adjust longer or shorter, but use the default
> only when we had no queries to update it.
>
>                                                 +-DLS
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
