From: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Subject: commit 1faa4356 breaks IPv6 assignment on libvirtd
Date: Thu, 01 Sep 2011 23:42:42 +0900
Message-ID: <4E5F99E2.50301@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:47754 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757624Ab1IAOmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 10:42:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

   Commit 1faa4356 break IPv6 assignment on libvirtd. The configuration for my VM bridge network is as such:

<network>
  <name>default</name>
  <forward mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0' />
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254' />
    </dhcp>
  </ip>
  <ip family='ipv6' address='2001:d30:113:504::1' prefix='64'>
  </ip>
</network>

    This configuration worked fine on kernel 2.6.38. Updating my distro kernel broke the setup. My colleague 
and I traced the problem and found that libvirtd failed because there wasn't any carrier on virbr0 interface 
due to the change introduced by that commit. How can this be fixed? Thanks in advance.

Regards,
Ang Way Chuang
