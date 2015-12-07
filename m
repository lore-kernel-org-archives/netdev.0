From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Mon, 7 Dec 2015 08:20:23 -0800
Message-ID: <CAEh+42jv0Udt1b+e877EpE19V75m50+pEd1Hup=Dee61w_JqMg@mail.gmail.com>
References: <CAKgT0Uc1bJRrzpLUdr3vOFkYZbcqP=J8wgOz1feF+u04aNBg1g@mail.gmail.com>
 <20151205.130313.1952213347830357234.davem@davemloft.net> <CAKgT0UfQCnz+oGfETZQs-nCP_QL_5qzngB+zC-e6ZN1-kV8C0Q@mail.gmail.com>
 <20151205.172742.1214683922564543621.davem@davemloft.net> <CAKgT0Udj2vNjqTO3HQKRoQajm-_Y6PdgQAu23Z8eQfnLRvsUiQ@mail.gmail.com>
 <CALx6S37rekP6c9umanJAFhzpBC=pvR6VBA6CvR13-n7rhFYT-Q@mail.gmail.com>
 <CAKgT0Uf4GGmeMKHZsr4ZPmRWxSDT4hEHpLr03SczQBJ8Ei6E4A@mail.gmail.com>
 <CALx6S36SdoYO6XJkwUQMtEO9OPm-Hb+qu9Kzt3Db7+ps9Wf4AQ@mail.gmail.com>
 <CAKgT0UdDrx8LWXzgGNfWZHY+XSMAmj7axK5Dn85+fJbghp+Cfg@mail.gmail.com> <5664F6BF.4060909@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	John Linville <linville@tuxdriver.com>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:54225 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753967AbbLGQUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2015 11:20:46 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id B9470204B0
	for <netdev@vger.kernel.org>; Mon,  7 Dec 2015 16:20:44 +0000 (UTC)
Received: from mail-vk0-f47.google.com (mail-vk0-f47.google.com [209.85.213.47])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CD4E2203A4
	for <netdev@vger.kernel.org>; Mon,  7 Dec 2015 16:20:43 +0000 (UTC)
Received: by vkha189 with SMTP id a189so105104505vkh.2
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 08:20:43 -0800 (PST)
In-Reply-To: <5664F6BF.4060909@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 6, 2015 at 7:02 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 12/6/15 6:20 PM, Alexander Duyck wrote:
>>
>> That works for Linux to Linux, but what about the cases where you have
>> a non-Linux endpoint on the other end such as something like a Cisco
>> switch?
>
>
> Why does is matter what kind of switch the NIC is connected to?

I think Cisco was just an example, not anything particular about their
switches. But there are two general problems:

 * Some protocols, like VXLAN, recommend that the UDP checksum be zero
so this is what pretty much everyone implements. As a result,
independent of the merits of using the checksum, most non-Linux
endpoints won't support it.

* The reason why this recommendation exists in the first place is that
most ASIC based switches can't compute/verify UDP checksums. They
slice off the headers and only run that through the chip's core
memory, so the rest of the packet isn't available to compute a
checksum over.
