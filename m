From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 0/2] net: ipv6: Improve user experience with
 multipath routes
Date: Thu, 26 Jan 2017 10:26:51 -0700
Message-ID: <c78afc85-8d18-0f63-68b3-63925e5d8c81@cumulusnetworks.com>
References: <1484892626-14257-1-git-send-email-dsa@cumulusnetworks.com>
 <90d6fdce-7780-b864-0e89-db262dec6fa1@cumulusnetworks.com>
 <20170124.110616.2098461870069191491.davem@davemloft.net>
 <4024f547-7f26-ab52-df9d-a0509048c7ff@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:34470 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753888AbdAZRe5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 12:34:57 -0500
Received: by mail-pg0-f46.google.com with SMTP id 14so73994169pgg.1
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 09:34:42 -0800 (PST)
In-Reply-To: <4024f547-7f26-ab52-df9d-a0509048c7ff@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/26/17 7:58 AM, Nicolas Dichtel wrote:
> Le 24/01/2017 à 17:06, David Miller a écrit :
>> From: David Ahern <dsa@cumulusnetworks.com>
>> Date: Fri, 20 Jan 2017 12:31:44 -0700
>>
>>> BTW, I am in favor of not requiring a user API for this but just
>>> doing it. I can't imagine anyone working with multipath routes not
>>> wanting the efficiency of the RTA_MULTIPATH attribute. These patches
>>> require an API only because of the rule not to break userspace. If
>>> we conclude to just do it without an API, the multipath_add and
>>> multipath_del need to be modified to only send a notification once
>>> at the end of the actions.
>>
>> After some consideration, I agree.
> Sorry for my late reply but I fear that this will break some userland apps like
> quagga.

Quagga does not properly handle IPv6 multipath routes received from the kernel. I checked this with debian/jessie version and our version, and Donald reviewed the source. It is broken.

This is a no-op to iproute2 -- it properly handles RTA_MULTIPATH for IPv6, though arguably scripts could exist parsing the existing series of routes. We could offer a switch to dump routes in the old format (opting in to the old behavior vs moving to the new consistent behavior).

libnl based apps work fine as of a patch Roopa got committed 4+ years ago.

> I agree that it would be better but the API is here since v3.8, ie 4 years.

What API are you referring to? You mean 51ebd3181572a?

I think this problem is a mixed bag. Currently, IPv6 multipath is completely different than IPv4 and MPLS. Adding an API to protect backward compatibility only shifts the problem -- it creates different APIs for IPv4 and IPv6 to get the same behavior. The middle ground is a sysctl that acts as a global switch to pick which difference you want with the caveat that it affects all apps in the namespace.

Consistency in behavior -- both API and data format -- is important for good, efficient userspace code. 
