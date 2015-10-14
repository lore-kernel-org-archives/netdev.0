From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [bug report or not] ping6 will lost packets when ping6 lots of
 ipv6 address
Date: Wed, 14 Oct 2015 14:44:22 +0800
Message-ID: <CAJFZqHyTfmvUQVAHf872_syRizxjQ6GfyWgb3nBnq0d-zQYP8A@mail.gmail.com>
References: <CAJFZqHwASEOG-atD=yvygra=Ah5awF+9drmgGZm7L2OoGam0DQ@mail.gmail.com>
	<20151013161145.GE88112@canlin-mbp1.DHCP.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:35425 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751551AbbJNGoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 02:44:23 -0400
Received: by qgt47 with SMTP id 47so34945584qgt.2
        for <netdev@vger.kernel.org>; Tue, 13 Oct 2015 23:44:22 -0700 (PDT)
In-Reply-To: <20151013161145.GE88112@canlin-mbp1.DHCP.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2015 at 12:11 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> On Tue, Oct 13, 2015 at 08:46:49PM +0800, Li RongQing wrote:
>> 1. in a machine, configure 3000 ipv6 address in one interface
>>
>> for i in {1..3000}; do ip -6 addr add 4001:5013::$i/0 dev eth0; done
>>
>>
>> 2. in other machine, ping6 the upper configured ipv6 address, then
>> lots of lost packets
>>
>> ip -6 addr add 4001:5013::0/64 dev eth0
>> for i in {1..2000}; do ping6 -q -c1 4001:5013::$i; done;
>>
>> 3. increasing the gc thresh can handles these lost
>>
>> sysctl -w  net.ipv6.neigh.default.gc_thresh1=2000
>> sysctl -w  net.ipv6.neigh.default.gc_thresh2=3000
>> sysctl -w  net.ipv6.neigh.default.gc_thresh3=4000
>> sysctl -w net.ipv6.route.gc_thresh=3000
>> sysctl -w net.ipv6.route.max_size =3000
> Which kernel is used in this test?

all version, I think this should not a bug, this test will lead to
that the neigh number is
larger than net.ipv6.neigh.default.gc_thresh3, and can not allocate
new neigh, and ping
will lost packets.

Thanks


-Roy
