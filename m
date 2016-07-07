From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 00/10] NCSI Support
Date: Thu, 7 Jul 2016 12:12:24 +0300
Message-ID: <CAJ3xEMgRqa_=MmPyRmOU=hUAF3o6N5A0dToa6hSwSut6QvosKw@mail.gmail.com>
References: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <CAJ3xEMjEup1VUeCr3g2Ry78HvprfnC6wjGd=MWjnMOLWdLyKdQ@mail.gmail.com> <20160705174433.GA73415@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, benh@kernel.crashing.org,
	joel@jms.id.au, weixue@trustnetic.com,
	Yuval Itkin <yuvali@mellanox.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:34817 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757089AbcGGJM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 05:12:26 -0400
Received: by mail-oi0-f45.google.com with SMTP id r2so15241070oih.2
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 02:12:26 -0700 (PDT)
In-Reply-To: <20160705174433.GA73415@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 5, 2016 at 8:44 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Mon, Jul 04, 2016 at 01:03:06AM +0300, Or Gerlitz wrote:

> Or, since cx4 has ncsi as well, could you do a thorough review of this
> to make sure that it fits mellanox nics as well?

Hi Alexei, all

Yuval from our team who deals with host management did review on the
series, SB his feedback.

1. The initialization uses a single unicast MAC address which hints it
assumes that the management traffic is IPv4 only. The infrastructure
does not seem to be ready for IPv6 based management traffic.

2. The code enables AEN messages (all the 3 messages defined by the
standard are enabled). AEN support mandates readiness on the BMC side
(running the reviewed code) and mandates support on the NIC. Not every
NIC can create AEN messages therefore I would recommend that the code
will only enable AENs which are declared as supported. To query
support for AEN messages, the BMC shall interpret the response for
"Get Capabilities" command and based on the returned response it can
detect which AEN message is supported by the NIC and may be enabled.

3. When stating support for NC-SI it is important to indicate which
exact version of NC-SI is supported (or required). From my observation
this code is based on NC-SI 1.0.0 as it does not use any of the
features which were introduced in the later versions.

4. HW arbitration is disabled in this implementation. It should be
defined how to add support to system which supports HW arbitration.

5. The code has an initialization sequence which is clear. Yet there
shall be a re-initialization sequence needed if a device goes through
asynchronous entry to initial state, which may happen if the NIC goes
through reset for any reason.

Or.
