From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Wed, 18 Jun 2008 16:17:36 +0200
Message-ID: <f4845fc0806180717x6b1a53eeo4db207dab26483c@mail.gmail.com>
References: <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com>
	 <48528EED.7090307@trash.net>
	 <f4845fc0806151714r515545b1l443200d3377b59ad@mail.gmail.com>
	 <485652EA.2020004@trash.net>
	 <f4845fc0806161619i4dc81dcao933d95aa6e09b45e@mail.gmail.com>
	 <4857A58E.6080304@trash.net> <20080617171840.GB4064@google.com>
	 <485819A8.1090004@trash.net>
	 <f4845fc0806171547v88ff4d3gc56e9c43a4176a14@mail.gmail.com>
	 <4858CDDF.4050306@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Simon Horman" <horms@verge.net.au>,
	"Vince Busam" <vbusam@google.com>,
	"Ben Greear" <greearb@candelatech.com>, lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:58666 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753692AbYFRORp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 10:17:45 -0400
Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id m5IEHcaJ017776
	for <netdev@vger.kernel.org>; Wed, 18 Jun 2008 15:17:38 +0100
Received: from yw-out-2324.google.com (ywe9.prod.google.com [10.192.5.9])
	by zps75.corp.google.com with ESMTP id m5IEHbnL021837
	for <netdev@vger.kernel.org>; Wed, 18 Jun 2008 07:17:37 -0700
Received: by yw-out-2324.google.com with SMTP id 9so149613ywe.59
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2008 07:17:37 -0700 (PDT)
In-Reply-To: <4858CDDF.4050306@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 18, 2008 at 10:57 AM, Patrick McHardy <kaber@trash.net> wrote:
>>> As I mentioned above, you usually want a MASK in combination
>>> with flags to allow to unset them. This is best done using
>>> a structure.
>>>
>>
>> Hm, I'm not sure if I understand exactly what this struct is supposed
>> to look like. Could you give an example?
>>
>
> struct {
>   u32 flags;
>   u32 mask;
> } flags;
>
> and then:
>
> obj->flags = (obj->flags & ~flags->mask) |
>                   (flags->flags | flags->mask);

Ah, I see. The second line should read "(flags->flags & flags->mask)", right?

Looking at how these "flags" are actually used in ipvsadm, I'm not
sure this would be needed here:

1) destination conn_flags are only set to successive integer values 0,
1, 2... (depending on the forwarding method), which are mutually
exclusive. Only internally in the kernel are other bits of this field
used in a flag-like fashion. So this Netlink attribute could be
renamed to something like *_FWD_METHOD and be a normal value field.

2) for the service flags, only one bit is set from userspace
(persistent/nonpersistent service). So this might be not too bad to
have as a single Netlink flag attribute.

Otherwise, I changed the interface according to your feedback and
we'll work on the implementation for a while now!

Thanks,
Julius

-- 
Google Switzerland GmbH
