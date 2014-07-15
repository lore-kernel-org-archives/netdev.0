From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH 1/2 net-next] vxlan: Be liberal on receive and only require
 the I bit to be set
Date: Tue, 15 Jul 2014 09:18:01 +0200
Message-ID: <53C4D5A9.1030008@6wind.com>
References: <cover.1405097440.git.tgraf@suug.ch> <cc7b11d065475a303d4a12a34acfded4e830c313.1405097440.git.tgraf@suug.ch> <CA+mtBx_VpbrddO3AMRZbZ3Qdkp2QBs5i7rN2tqD4GFM0hT7zYg@mail.gmail.com> <20140714081802.GA19186@casper.infradead.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	xiyou.wangcong@gmail.com, Or Gerlitz <ogerlitz@mellanox.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Pritesh Kothari (pritkoth)" <pritkoth@cisco.com>,
	Madhu Challa <challa@noironetworks.com>
To: Thomas Graf <tgraf@suug.ch>, Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:56569 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757712AbaGOHSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 03:18:05 -0400
Received: by mail-wi0-f174.google.com with SMTP id d1so3806523wiv.1
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 00:18:03 -0700 (PDT)
In-Reply-To: <20140714081802.GA19186@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/07/2014 10:18, Thomas Graf a =E9crit :
> On 07/13/14 at 03:08pm, Tom Herbert wrote:
>> On Fri, Jul 11, 2014 at 9:59 AM, Thomas Graf <tgraf@suug.ch> wrote:
>>> The VXLAN receive code is currently conservative in what it accepts=
 and
>>> will reject any frame that uses any of the reserved fields. The VXL=
AN
>>> draft specifies that "reserved fields MUST be set to zero on transm=
it
>>> and ignored on receive." though.
>>>
>>> Be liberal in only requiring the I bit to allow for VXLAN extension=
s
>>> to be implemented.
>>>
>> This is not robust (this is a problem in the VXLAN spec not your
>> patch). There is no requirement that the VXLAN bits are optional. Fo=
r
>> example, if a receiver accepts a GPE packet but doesn't implement it
>> the packet will be misinterpreted. I've already pointed this out to
>> the VLXAN folks on nvo3 list. Dropping packets with unknown bits set
>> is the only sane approach.
>
> I agree, it's a mess.
+1
