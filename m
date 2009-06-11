From: Chaitanya Lala <clala@riverbed.com>
Subject: How to configure MDI status per port
Date: Wed, 10 Jun 2009 21:19:22 -0700
Message-ID: <4A3085CA.2000300@riverbed.com>
Reply-To: clala@riverbed.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	Arthur Jones <ajones@riverbed.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from autosupport.riverbed.com ([208.70.196.44]:58186 "EHLO
	smtp2.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755448AbZFKESR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 00:18:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a requirement to be able to configure/change the default MDI-X 
status of each ethernet port. This should be possible on a per port 
basis i.e. it should be possible to configure, say, port 0 to auto mdi-x 
mode & port 1 to manual MDI-X mode. A couple of possible implementation 
strategies could achieve this but both have some problems. Following is 
an overview of the two.

1.) Use a module parameter. Pass an array of values, each value 
corresponding to ethernet port supported by the driver. For example, 
modprobe e1000e mdix_values=1,0,2,0 (where the numbers 0,1 & 2 represent 
auto MDI-X, manual MDI  & manual MDI-X modes respectively) assigns value 
1 for port 0, 0 for port 1, 2 for port 2 and so on. This value can be 
assigned to the mdix parameter (member of the e1000_phy_info structure 
in the case of e1000e driver) in the probe routine. The problem here is 
how to map the ordered list of numbers to the ethernet ports so that 
each number in the list always corresponds to the same ethernet 
interface. I assume that the order of enumeration of ethernet ports can 
change based on changes to the system topology, i.e. plugging/pulling of 
additional NIC cards.

2.) Using ethtool and each driver sets the value in its set_settings 
function (part of the ethtool operations structure). The value received 
for each port can be assigned to the mdix parameter (member of the 
e1000_phy_info structure in the case of e1000e driver) but the problem 
is that the value is useful iff it is assigned before the probe routine 
is invoked, because the settings in the chip registers are done only at 
probe time. Is there a way to change this value and have it take effect 
when changed by ethtool?

Any other ideas are most welcome.

Thanks,
Chaitanya
