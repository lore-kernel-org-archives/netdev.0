From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 11:06:55 -0700
Message-ID: <CA+mtBx9=wp5T4HxZHVPU4if-BxPaU6Mb+u9PFP6vXicoaosg1A@mail.gmail.com>
References: <CA+mtBx_y0hK69jcdY5e0MUzAa8hEPwExBDuK9Dn4Ceo5Hkn_iw@mail.gmail.com>
	<20130924.113953.1275344954032811572.davem@redhat.com>
	<CA+mtBx_AcmcNBDhRKVB8YDkSNdOwgJ3CXxBqpgxDw23X3m2rvQ@mail.gmail.com>
	<20130924.140312.1944338200709799169.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Laight <David.Laight@aculab.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:46652 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754161Ab3IXSG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 14:06:56 -0400
Received: by mail-ie0-f172.google.com with SMTP id x13so9542860ief.17
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 11:06:56 -0700 (PDT)
In-Reply-To: <20130924.140312.1944338200709799169.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 11:03 AM, David Miller <davem@redhat.com> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Tue, 24 Sep 2013 08:54:24 -0700
>
>> On Tue, Sep 24, 2013 at 8:39 AM, David Miller <davem@redhat.com> wrote:
>>> From: Tom Herbert <therbert@google.com>
>>> Date: Tue, 24 Sep 2013 08:22:55 -0700
>>>
>>>> We use this value for steering, and could use it for other uses like
>>>> connection lookup.
>>>
>>> For security reasons we absolutely cannot use it for that purpose,
>>> please stop claiming this.
>>>
>>> Any hash function which an attacker can reproduce is attackable.
>>
>> The Toeplitz function uses a secret key whose length is based on the
>> input length.  96 bits in IPv4, 320 bits in IPv6.  I don't see how an
>> attacker can reproduce this if the key is random.  If the problem is
>> that devices are not being configured with a sufficiently random key
>> (some actually are using a fixed key :-( ), that's a separate issue
>> that should be addressed.  It is possible to DoS attack through the
>> steering mechanism.
>
> All of them are using a fixed, defined, key.

bnx2x, at least, seems to being trying to set a random key:

prandom_bytes(params.rss_key, T_ETH_RSS_KEY * 4);
