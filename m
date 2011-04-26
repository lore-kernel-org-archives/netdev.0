From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: how to set vlan filter for intel 82599
Date: Tue, 26 Apr 2011 14:31:44 +0100
Message-ID: <1303824705.3032.359.camel@localhost>
References: <BANLkTikZcdda5-3NBaXyKmij09f62Da3cQ@mail.gmail.com>
	 <1303786638.3032.307.camel@localhost>
	 <BANLkTikav_NimAoFj_2Wo-BMD-3uVjU--w@mail.gmail.com>
	 <1303789868.3032.347.camel@localhost>
	 <BANLkTi=eADSYV90EC9uJhtLZfBBJa5O1Bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: zhou rui <zhourui.cn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:15573 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754982Ab1DZNbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 09:31:48 -0400
In-Reply-To: <BANLkTi=eADSYV90EC9uJhtLZfBBJa5O1Bw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-26 at 12:39 +0800, zhou rui wrote:
[...]
> i set the filter like below:
> 
> for a vlanid=50, it always match the last rule (action 7)
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

Check dmesg; there should be an error message there.  Of course the
error code should be EINVAL and not EPERM.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

