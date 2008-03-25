From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [Bugme-new] [Bug 10322] New: e1000 is not auto-negotiating to
 1GB full duplex speed even there is 1GB speed availble
Date: Tue, 25 Mar 2008 15:02:56 -0700
Message-ID: <47E97690.7020404@intel.com>
References: <bug-10322-10286@http.bugzilla.kernel.org/> <20080325123654.91f80b00.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lqs_xting@sohu.com, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:15197 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754549AbYCYWL4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 18:11:56 -0400
In-Reply-To: <20080325123654.91f80b00.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
>> Hardware Environment: e1000 with 82571 chip
>> Software Environment: CentOS 4.5
>> Problem Description:
>> We have a machine with the e1000(82571) driver which could not detect the
>> correct link mode with a switch supports 1000 Mbps/s. I just find that the
>> ethtool can't support 10 Mbps/s Half and 1000 Mbps/s Full mode. Therefore, the
>> e1000 code should be fixed by add all modes at the 216 lines in
>> e1000_ethtool.c. It is as follow:
>>
>> hw->autoneg_advertised |= ecmd->advertising |
>>                          ADVERTISED_TP |
>>                          ADVERTISED_Autoneg;
>>
>>
>> Steps to reproduce:
>> 1. Add a entry ' ETHTOOL_OPTS="autoneg on" ' in the
>> /etc/sysconfig/network-scripts/ifcfg-eth0;
>> 2. Run '/etc/init.d/network restart';
>> 3. Run 'ethtool eth0', it displays the speed is 100 Mbps/s. But the real link
>> mode should be 1000 Mbps/s

a bit moot because 82571 support is moving to e1000e and thus I will (probably)
not fix this bug. all 82571 support will be removed from e1000 from 2.6.26 onwards.

Please re-test against e1000e from 2.6.25-rc5 - if the bug is still in that driver
then we need to look at it again. Either that or reproduce against an 8254x adapter?

Auke


