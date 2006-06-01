From: varun <varun@rocsys.com>
Subject: netfilter reg problem
Date: Thu, 01 Jun 2006 11:33:57 +0530
Message-ID: <447E834D.4090409@rocsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from 59.162.194.138.static.vsnl.net.in ([59.162.194.138]:32480 "EHLO
	rocsys.com") by vger.kernel.org with ESMTP id S1751800AbWFAFz2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jun 2006 01:55:28 -0400
Received: from mail.rocsys.com (localhost [127.0.0.1] (may be forged))
	by rocsys.com (8.12.10/8.12.10) with ESMTP id k4VKq9YJ015938
	for <netdev@vger.kernel.org>; Thu, 1 Jun 2006 22:26:27 +0530
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

            I have a setup where iam using iptables. I have squid 
running on my statem. Now the scenario is that this sytem is my router. 
I have eth0 connected to LAN, eth1 to Wan 1 and eth2 to Wan2. In the 
same box i also have a propratery FW which has Load Balancing feature.  
Now my intention is i start iptables first so that it registers with 
netfilter hook first.
So policy is like this
      iptables -t nat -D PREROUTING -i eth0 -p tcp -j REDIRECT --to-port 
8080
 In the port 8080 i have squid running.
 As far as filtering of iptables is concerned it is allow all.

     So my basic FW functionality is concerned it is taken care by My 
Propratery FW. It will do  the natting for both wan interfaces in Load 
balance.

  Now what i expect is that iptables will get all the packets first and 
then packet will go to my firewall and might get dropped if ACL matches 
else it is success. Once success i expect the packet to be redirected to 
port 8080 where squid can take control.

 Now my problem is that even though iptables is registered first when i 
log the packets using iptables for the above rule i find that no packets 
are comming to iptables there by no packets are going to proxy. I get 
only some multicast packets.

 From lan iam able to browse well and all my traffic is going tru my FW 
rather that first through iptables. Why?

As far as my knowledge first registered module get the packet first and 
if the action is NF_ACCEPT the the next registered module to the hook 
gets it right? If yes why is it not happening? Another thing is what 
exactly does redirect do does it mangel the packet?

Please help me in this?

Varun
