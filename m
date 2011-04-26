From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: how to set vlan filter for intel 82599
Date: Tue, 26 Apr 2011 08:22:55 -0700
Message-ID: <4DB6E34F.5000203@intel.com>
References: <BANLkTikZcdda5-3NBaXyKmij09f62Da3cQ@mail.gmail.com>	 <1303786638.3032.307.camel@localhost>	 <BANLkTikav_NimAoFj_2Wo-BMD-3uVjU--w@mail.gmail.com>	 <1303789868.3032.347.camel@localhost>	 <BANLkTi=eADSYV90EC9uJhtLZfBBJa5O1Bw@mail.gmail.com> <1303824705.3032.359.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: zhou rui <zhourui.cn@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50511 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752796Ab1DZPXj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2011 11:23:39 -0400
In-Reply-To: <1303824705.3032.359.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/26/2011 6:31 AM, Ben Hutchings wrote:
> On Tue, 2011-04-26 at 12:39 +0800, zhou rui wrote:
> [...]
>> i set the filter like below:
>>
>> for a vlanid=50, it always match the last rule (action 7)
>>
>> ./ethtool -K eth5 ntuple off
>> ./ethtool -K eth5 ntuple on
>> ./ethtool -U eth5 flow-type tcp4 vlan 32 vlan-mask 0xF01F action 1
>> ./ethtool -U eth5 flow-type udp4 vlan 32 vlan-mask 0xF01F action 1
>> ./ethtool -U eth5 flow-type udp4 vlan 64 vlan-mask 0xF01F action 7
>> ./ethtool -U eth5 flow-type tcp4 vlan 64 vlan-mask 0xF01F action 7
>>
>> I tried the latest ixgbe driver 3.3.9, it reports:
>>
>> Cannot add new RX n-tuple filter: Operation not permitted
>>
>> ./ethtool -V
>> ethtool version 2.6.36
>
> Check dmesg; there should be an error message there.  Of course the
> error code should be EINVAL and not EPERM.
>
> Ben.
>

The problem is likely the vlan-mask.  The only valid VLAN masks 
supported are 0xFFFF, 0x0FFF, 0xF000, and 0x0000.  The hardware cannot 
partially mask either the priority nor the VLAN TCI.

Thanks,

Alex
