From: "Laurent Chavey" <chavey@google.com>
Subject: bond_compute_features() does not handle devices with different CSUM
Date: Tue, 29 May 2007 17:41:45 -0700
Message-ID: <97949e3e0705291741t4c485d38ud48b06e6d07e31bc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:10126 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbXE3Al7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2007 20:41:59 -0400
Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id l4U0ftu3030670
	for <netdev@vger.kernel.org>; Tue, 29 May 2007 17:41:55 -0700
Received: from ug-out-1314.google.com (ugn78.prod.google.com [10.66.14.78])
	by zps76.corp.google.com with ESMTP id l4U0fkFk009808
	for <netdev@vger.kernel.org>; Tue, 29 May 2007 17:41:46 -0700
Received: by ug-out-1314.google.com with SMTP id 78so65815ugn
        for <netdev@vger.kernel.org>; Tue, 29 May 2007 17:41:45 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kernel version <= 2.6.20.1
file drivers/net/bonding/bonding_main.c
function bond_compute_features()

-----------
  Given a system with two different NIC. One driver sets
        dev->features |=  NETIF_F_HW_CSUM
  the other driver sets
        dev->features |=  NETIF_F_IP_CSUM

  when enslaving the 2 device above, bond_compute_features()
  does not set the intersection of the 2 CSUM
  features (should be NETIF_F_IP_CSUM)
-----------

   should the bond features in the case above include NETIF_F_IP_CSUM
