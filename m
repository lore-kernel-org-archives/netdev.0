From: zhou rui <zhourui.cn@gmail.com>
Subject: Re: how to set vlan filter for intel 82599
Date: Tue, 26 Apr 2011 11:39:18 +0800
Message-ID: <BANLkTikav_NimAoFj_2Wo-BMD-3uVjU--w@mail.gmail.com>
References: <BANLkTikZcdda5-3NBaXyKmij09f62Da3cQ@mail.gmail.com>
	<1303786638.3032.307.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:40906 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757979Ab1DZDjT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 23:39:19 -0400
Received: by iyb14 with SMTP id 14so194239iyb.19
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 20:39:18 -0700 (PDT)
In-Reply-To: <1303786638.3032.307.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2011 at 10:57 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Tue, 2011-04-26 at 10:19 +0800, zhou rui wrote:
>> hi
>> here is the problem troubles me,how to set vlan filter for intel
>> 82599? for example
>> I want vlan id 0~31 will go to queue 0, vlan id 32-63 will go to que=
ue
>> 1...below is my setting,but doesn't work
>>
>> don't know the exact meanning of the vlan-mask and vlan,how are they=
 calculated?
>>
>> ./ethtool -K eth5 ntuple on
>>
>> ./ethtool -U eth5 flow-type udp4 src-ip 0x0 src-ip-mask 0x0 dst-ip 0=
x0
>> dst-ip-mask 0x0 src-port 0x0 src-port-mask 0x0 dst-port 0x0
>> dst-port-mask 0x0 vlan 0x0000 vlan-mask 0x00E0 user-def 0x0
>> user-def-mask 0x0 action 0
> [...]
>
> This specifies a filter for UDP/IPv4 packets, and the masks are wrong=
=2E
> If you actually wanted to filter only UDP/IPv4 packets for VID 0-31 t=
hen
> the correct syntax would be:
>
> =A0 =A0ethtool -U eth5 flow-type udp4 vlan 0 vlan-mask 0xf01f
>
> If you don't care about the layer 3/4 protocols then you would need t=
o
> use 'flow-type ether', but no driver implements that yet. =A0(Well, s=
fc
> implements the *type*, but not filtering by VID only.)
>
> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>

hi ben,thanks for your help,would you mind tell me "32~63" VID filter?
still can not understand the vlan-mask
