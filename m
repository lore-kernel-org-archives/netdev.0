From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with
 no group
Date: Wed, 19 Mar 2014 21:52:31 +0200
Message-ID: <CAF1J0HPT3u05uu6uLYDDu7cV11Ku6AHVooSLLAoaYj6wVtfemA@mail.gmail.com>
References: <1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>
	<OFEB1030F8.C147FA77-ON87257C9F.005CF370-87257C9F.005CF375@us.ibm.com>
	<CAF1J0HOTLvyaWdmYLGLPn9AJLR6rQr4fk8EVFSzv5sckLuBwvw@mail.gmail.com>
	<20140319.154649.1043650085697557640.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Stevens <dlstevens@us.ibm.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:53540 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753978AbaCSTwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 15:52:32 -0400
Received: by mail-oa0-f43.google.com with SMTP id eb12so3616769oac.30
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 12:52:32 -0700 (PDT)
In-Reply-To: <20140319.154649.1043650085697557640.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 19, 2014 at 9:46 PM, David Miller <davem@davemloft.net> wrote:
> From: Mike Rapoport <mike.rapoport@ravellosystems.com>
> Date: Wed, 19 Mar 2014 09:14:46 +0200
>
>> On Tue, Mar 18, 2014 at 10:55:16AM -0600, David Stevens wrote:
>>>
>>> Wouldn't it be better to:
>>>
>>> 1) make sure all of vxlan_dev is initialized before use,
>>> especially default_dst
>>> 2) change the v6 code to check for AF_INET6 too, and do
>>> nothing if not set. If not set by the admin, the family of
>>> default_dst would then be AF_UNSPEC and not match.
>>
>> The family of default dst is implicitly initailized to AF_UNSPEC because
>> if kzalloc :)
>>
>> I agree that explicit check for AF_INET6 is much better than fallthrough
>> with simple 'else' clause and I can send a patch that makes the checks
>> for IPv6 as well as default_dst initialization explicit
>>
>> However, for the particular case in vxlan_rcv, checking the packet
>> version seems to me semantically more correct than comparing default_dst
>> protocol family with AF_INET or AF_INET6.
>
> The way I read things, we would receive packets unconditionally in the
> pre-ipv6-support code.  So we have to keep doing so.
>
> Therefore we either have to check the SKB protocol or pass an explicit
> protocol as an argument to vs->rcv(...).

Well, the patch I've sent checks for ip_hdr(skb) protocol version...

-- 
Sincerely yours,
Mike.
