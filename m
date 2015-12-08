From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net-next 3/3] geneve: Remote Checksum Offload support
Date: Tue, 8 Dec 2015 15:58:17 -0800
Message-ID: <CAEh+42gMC7SSuSsJncxvFCeqJAGA4_DZs2qq3n1NRV7JHYu9SA@mail.gmail.com>
References: <1449599238-4094072-1-git-send-email-tom@herbertland.com>
 <1449599238-4094072-4-git-send-email-tom@herbertland.com> <20151208193150.GH3598@tuxdriver.com>
 <CALx6S36dU-RLUSTTZz8dVZHD7=p3=modbjUOePKMYG96FrA_zA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:56789 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751133AbbLHX6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 18:58:40 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 5977120490
	for <netdev@vger.kernel.org>; Tue,  8 Dec 2015 23:58:39 +0000 (UTC)
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B58E22045A
	for <netdev@vger.kernel.org>; Tue,  8 Dec 2015 23:58:37 +0000 (UTC)
Received: by qgcc31 with SMTP id c31so45551925qgc.3
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 15:58:36 -0800 (PST)
In-Reply-To: <CALx6S36dU-RLUSTTZz8dVZHD7=p3=modbjUOePKMYG96FrA_zA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 8, 2015 at 11:59 AM, Tom Herbert <tom@herbertland.com> wrote:
> On Tue, Dec 8, 2015 at 11:31 AM, John W. Linville
> <linville@tuxdriver.com> wrote:
>> On Tue, Dec 08, 2015 at 10:27:18AM -0800, Tom Herbert wrote:
>>> Add support for remote checksum offload in both the normal and GRO
>>> paths. netlink command are used to enable sending of the Remote
>>> Checksum Data, and allow processing of it on receive. The Remote
>>
> Extraneous.
>
>> afsO&^(*&5^a+++NO CARRIER
>>
>> Did you mean to finish that sentence? ;-)
>>
>>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>>
>> Jesse is going to have to comment on your (ab)use of the reserved
>> fields.  I presume that an RFC would be forthcoming?
>>
> I'll spin an I-D once there is agreement on the approach. This is
> identical to VXLAN excepted the bit flag indicating csum_start is
> present might be different.

Thanks for doing this - it was also on my to-do list.

We can definitely do better than VXLAN here since there is
extensibility built into the protocol. I think the right way to do
this is to define a TLV option and then use the same format as what
you defined for GUE (and it is also nice to reuse some of the option
formats to minimize differences across protocols).

I'd like to set up an IANA registry for classes but that's a little
slow going at this point, so for the next draft update I'm planning on
adding some initial assignments, including a Linux class. We could
then allocate remote checksum out of that. The new version of the
draft should be coming out pretty soon.
