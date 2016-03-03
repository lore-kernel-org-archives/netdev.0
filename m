From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [iproute PATCH 3/3] tc: pedit: Fix retain value for ihl
 adjustments
Date: Thu, 3 Mar 2016 09:21:23 -0500
Message-ID: <56D84863.5090203@mojatatu.com>
References: <1456917631-18447-1-git-send-email-phil@nwl.cc>
 <499abfe479324d1e83289cd68b2a7641@HQ1WP-EXMB11.corp.brocade.com>
 <20160302095414.45a928df@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>, Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33560 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757895AbcCCOVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 09:21:38 -0500
Received: by mail-io0-f194.google.com with SMTP id g203so2267858iof.0
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 06:21:37 -0800 (PST)
In-Reply-To: <20160302095414.45a928df@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-03-02 12:54 PM, Stephen Hemminger wrote:
> On Wed, 2 Mar 2016 11:20:31 +0000
> Phil Sutter <phil@nwl.cc> wrote:
>
>> +		res = parse_cmd(&argc, &argv, 1, TU32,0x0f,sel,tkey);
>>   		goto done;
> Please add whitespace after ,
>

There are a few whitespace issues in that code that would be nice to fix
given the cleanup opportunity.
The patches look good to me. Phil, maybe get rid of that comment at the
top which was worrying about endianness. I think you fixed it.

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

Your tests in patch 0 are nice and could go in tests/ directory.
I can send you some of the basic tests i run via the kernel; they look
something of the form:

#
#RFC
#dst MAC starts at -14
#src MAC at -8
#ethertype at -2
#
#
tc filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
match ip src 192.168.1.10/32 flowid 1:2 \
action pedit munge offset -14 u16 set 0x0000 \
munge offset -12 u32 set 0x00010100 \
munge offset -8 u32 set 0x0aaf0100 \
munge offset -4 u32 set 0x0008ec06 pipe \
action mirred egress redirect dev eth1
#
#

These would of course require more of a larger setup to vet
and running tcpdump to check the correct bytes are being
modified.

cheers,
jamal
