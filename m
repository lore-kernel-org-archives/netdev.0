From: zhou rui <zhourui.cn@gmail.com>
Subject: Re: how to set vlan filter for intel 82599
Date: Tue, 26 Apr 2011 12:39:53 +0800
Message-ID: <BANLkTi=eADSYV90EC9uJhtLZfBBJa5O1Bw@mail.gmail.com>
References: <BANLkTikZcdda5-3NBaXyKmij09f62Da3cQ@mail.gmail.com>
	<1303786638.3032.307.camel@localhost>
	<BANLkTikav_NimAoFj_2Wo-BMD-3uVjU--w@mail.gmail.com>
	<1303789868.3032.347.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:62303 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495Ab1DZEjx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 00:39:53 -0400
Received: by iyb14 with SMTP id 14so216801iyb.19
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 21:39:53 -0700 (PDT)
In-Reply-To: <1303789868.3032.347.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2011 at 11:51 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Tue, 2011-04-26 at 11:39 +0800, zhou rui wrote:
>> On Tue, Apr 26, 2011 at 10:57 AM, Ben Hutchings
>> <bhutchings@solarflare.com> wrote:
>> > On Tue, 2011-04-26 at 10:19 +0800, zhou rui wrote:
>> >> hi
>> >> here is the problem troubles me,how to set vlan filter for intel
>> >> 82599? for example
>> >> I want vlan id 0~31 will go to queue 0, vlan id 32-63 will go to =
queue
>> >> 1...below is my setting,but doesn't work
>> >>
>> >> don't know the exact meanning of the vlan-mask and vlan,how are t=
hey calculated?
>> >>
>> >> ./ethtool -K eth5 ntuple on
>> >>
>> >> ./ethtool -U eth5 flow-type udp4 src-ip 0x0 src-ip-mask 0x0 dst-i=
p 0x0
>> >> dst-ip-mask 0x0 src-port 0x0 src-port-mask 0x0 dst-port 0x0
>> >> dst-port-mask 0x0 vlan 0x0000 vlan-mask 0x00E0 user-def 0x0
>> >> user-def-mask 0x0 action 0
>> > [...]
>> >
>> > This specifies a filter for UDP/IPv4 packets, and the masks are wr=
ong.
>> > If you actually wanted to filter only UDP/IPv4 packets for VID 0-3=
1 then
>> > the correct syntax would be:
>> >
>> > =A0 =A0ethtool -U eth5 flow-type udp4 vlan 0 vlan-mask 0xf01f
>> >
>> > If you don't care about the layer 3/4 protocols then you would nee=
d to
>> > use 'flow-type ether', but no driver implements that yet. =A0(Well=
, sfc
>> > implements the *type*, but not filtering by VID only.)
> [...]
>> hi ben,thanks for your help,would you mind tell me "32~63" VID filte=
r?
>> still can not understand the vlan-mask
>
> The vlan-mask specifies tag bits to be ignored. =A0You want to ignore=
 the
> priority, CFI and lower 5 bits of the VID, hence 0xf01f. =A0For a
> different group of 32 VIDs you would only change the vlan argument, n=
ot
> the vlan-mask argument.
>
> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>
i set the filter like below:

for a vlanid=3D50, it always match the last rule (action 7)

=2E/ethtool -K eth5 ntuple off
=2E/ethtool -K eth5 ntuple on
=2E/ethtool -U eth5 flow-type tcp4 vlan 32 vlan-mask 0xF01F action 1
=2E/ethtool -U eth5 flow-type udp4 vlan 32 vlan-mask 0xF01F action 1
=2E/ethtool -U eth5 flow-type udp4 vlan 64 vlan-mask 0xF01F action 7
=2E/ethtool -U eth5 flow-type tcp4 vlan 64 vlan-mask 0xF01F action 7

I tried the latest ixgbe driver 3.3.9, it reports:

Cannot add new RX n-tuple filter: Operation not permitted

=2E/ethtool -V
ethtool version 2.6.36

thanks!
