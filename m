From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: how to set vlan filter for intel 82599
Date: Tue, 26 Apr 2011 04:51:08 +0100
Message-ID: <1303789868.3032.347.camel@localhost>
References: <BANLkTikZcdda5-3NBaXyKmij09f62Da3cQ@mail.gmail.com>
	 <1303786638.3032.307.camel@localhost>
	 <BANLkTikav_NimAoFj_2Wo-BMD-3uVjU--w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zhou rui <zhourui.cn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:30500 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758026Ab1DZDvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 23:51:11 -0400
In-Reply-To: <BANLkTikav_NimAoFj_2Wo-BMD-3uVjU--w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-26 at 11:39 +0800, zhou rui wrote:
> On Tue, Apr 26, 2011 at 10:57 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> > On Tue, 2011-04-26 at 10:19 +0800, zhou rui wrote:
> >> hi
> >> here is the problem troubles me,how to set vlan filter for intel
> >> 82599? for example
> >> I want vlan id 0~31 will go to queue 0, vlan id 32-63 will go to queue
> >> 1...below is my setting,but doesn't work
> >>
> >> don't know the exact meanning of the vlan-mask and vlan,how are they calculated?
> >>
> >> ./ethtool -K eth5 ntuple on
> >>
> >> ./ethtool -U eth5 flow-type udp4 src-ip 0x0 src-ip-mask 0x0 dst-ip 0x0
> >> dst-ip-mask 0x0 src-port 0x0 src-port-mask 0x0 dst-port 0x0
> >> dst-port-mask 0x0 vlan 0x0000 vlan-mask 0x00E0 user-def 0x0
> >> user-def-mask 0x0 action 0
> > [...]
> >
> > This specifies a filter for UDP/IPv4 packets, and the masks are wrong.
> > If you actually wanted to filter only UDP/IPv4 packets for VID 0-31 then
> > the correct syntax would be:
> >
> >    ethtool -U eth5 flow-type udp4 vlan 0 vlan-mask 0xf01f
> >
> > If you don't care about the layer 3/4 protocols then you would need to
> > use 'flow-type ether', but no driver implements that yet.  (Well, sfc
> > implements the *type*, but not filtering by VID only.)
[...]
> hi ben,thanks for your help,would you mind tell me "32~63" VID filter?
> still can not understand the vlan-mask

The vlan-mask specifies tag bits to be ignored.  You want to ignore the
priority, CFI and lower 5 bits of the VID, hence 0xf01f.  For a
different group of 32 VIDs you would only change the vlan argument, not
the vlan-mask argument.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

