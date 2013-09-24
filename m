From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 12:04:25 -0700
Message-ID: <CA+mtBx8Nm_wQcizqD7ku5xONurqQaGZpqX0AafUrC7+4uU34xQ@mail.gmail.com>
References: <CA+mtBx_y0hK69jcdY5e0MUzAa8hEPwExBDuK9Dn4Ceo5Hkn_iw@mail.gmail.com>
	<20130924.113953.1275344954032811572.davem@redhat.com>
	<CA+mtBx_AcmcNBDhRKVB8YDkSNdOwgJ3CXxBqpgxDw23X3m2rvQ@mail.gmail.com>
	<20130924.140312.1944338200709799169.davem@redhat.com>
	<20130924114853.00003935@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@redhat.com>,
	David Laight <David.Laight@aculab.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:33700 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754253Ab3IXTE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 15:04:26 -0400
Received: by mail-ie0-f180.google.com with SMTP id u16so9328714iet.39
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 12:04:26 -0700 (PDT)
In-Reply-To: <20130924114853.00003935@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 11:48 AM, Jesse Brandeburg
<jesse.brandeburg@intel.com> wrote:
> On Tue, 24 Sep 2013 14:03:12 -0400 David Miller <davem@redhat.com> wrote:
> ...
>> >> For security reasons we absolutely cannot use it for that purpose,
>> >> please stop claiming this.
>> >>
>> >> Any hash function which an attacker can reproduce is attackable.
>> >
> ...
>> > that should be addressed.  It is possible to DoS attack through the
>> > steering mechanism.
>>
>> All of them are using a fixed, defined, key.
>
> We selected the fixed key on purpose.  The existing mechanisms built
> into the stack for preventing the impact of DOS attacks like NAPI
> polling will prevent any actual damage even if someone sends lots of
> packets on a single flow.  If someone overflows a receive queue that
> CPU runs until it can't keep up and then hardware drops further
> packets.  In this case even with a randomized seed key any single flow
> can still be targeted at a queue, which is no different than a single
> queue adapter.
>
> I'm not convinced there is an actual impact in practice.
>
But what is the purpose of using a fixed key, what are the benefits?
A clever attacker could attack a specific queue with different
4-tuples.  While this might be similar to a single flow attack, it
will be much harder to detect and be used to attack multiple servers
simultaneously in the say way (since they all share the same key).  I
don't think we could deploy a NIC with a static RSS key.
