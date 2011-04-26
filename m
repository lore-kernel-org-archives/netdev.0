From: zhou rui <zhourui.cn@gmail.com>
Subject: Re: how to set vlan filter for intel 82599
Date: Tue, 26 Apr 2011 23:30:54 +0800
Message-ID: <BANLkTimaCyCW4TYg30=CECe96vHxiStHfQ@mail.gmail.com>
References: <BANLkTikZcdda5-3NBaXyKmij09f62Da3cQ@mail.gmail.com>
	<1303786638.3032.307.camel@localhost>
	<BANLkTikav_NimAoFj_2Wo-BMD-3uVjU--w@mail.gmail.com>
	<1303789868.3032.347.camel@localhost>
	<BANLkTi=eADSYV90EC9uJhtLZfBBJa5O1Bw@mail.gmail.com>
	<1303824705.3032.359.camel@localhost>
	<4DB6E34F.5000203@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44601 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756389Ab1DZPaz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 11:30:55 -0400
Received: by iyb14 with SMTP id 14so597126iyb.19
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 08:30:55 -0700 (PDT)
In-Reply-To: <4DB6E34F.5000203@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, April 26, 2011, Alexander Duyck <alexander.h.duyck@intel.co=
m> wrote:
> On 4/26/2011 6:31 AM, Ben Hutchings wrote:
>
> On Tue, 2011-04-26 at 12:39 +0800, zhou rui wrote:
> [...]
>
> i set the filter like below:
>
> for a vlanid=3D50, it always match the last rule (action 7)
>
> ./ethtool -K eth5 ntuple off
> ./ethtool -K eth5 ntuple on
> ./ethtool -U eth5 flow-type tcp4 vlan 32 vlan-mask 0xF01F action 1
> ./ethtool -U eth5 flow-type udp4 vlan 32 vlan-mask 0xF01F action 1
> ./ethtool -U eth5 flow-type udp4 vlan 64 vlan-mask 0xF01F action 7
> ./ethtool -U eth5 flow-type tcp4 vlan 64 vlan-mask 0xF01F action 7
>
> I tried the latest ixgbe driver 3.3.9, it reports:
>
> Cannot add new RX n-tuple filter: Operation not permitted
>
> ./ethtool -V
> ethtool version 2.6.36
>
>
> Check dmesg; there should be an error message there. =A0Of course the
> error code should be EINVAL and not EPERM.
>
> Ben.
>
>
>
> The problem is likely the vlan-mask. =A0The only valid VLAN masks sup=
ported are 0xFFFF, 0x0FFF, 0xF000, and 0x0000. =A0The hardware cannot p=
artially mask either the priority nor the VLAN TCI.
>
> Thanks,
>
> Alex
>
Yes i just checked the log, it said partially vlan Id not support,
that means I can't set this filter?(vlan id 0-31 go to
Q0,32-63->Q1....?)
