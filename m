From: "V. Lavrov" <lve@guap.ru>
Subject: [RFC] LXC and network namespace issue
Date: Thu, 27 Feb 2014 17:21:22 +0400
Message-ID: <530F3BD2.9090204@guap.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.guap.ru ([91.151.188.3]:31314 "EHLO mx1.guap.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813AbaB0Nxq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 08:53:46 -0500
Received: from [10.0.0.64] ([10.0.0.64])
	(user=lve mech=CRAM-MD5 bits=0)
	by mail.guap.ru (8.14.7/8.14.4) with ESMTP id s1RDLMlV016678
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 17:21:22 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The problem with stoping/restarting the container.

Upon completion of the container, the parent process received signal SIGCHLD and exit code (by waitpid()).

During the 10-25ms after the completion of the container, we can not create vlan-interface (for restart).
The system returns an error codeEEXIST.

Another problem with the network interface type "phys".
Before running the container we save ifindex network physical interface (by if_nametoindex()).
We need to restore the name of network interface have the type phys (by saved ifindex) upon completion of the container,
  but the system returns an error ENODEV. 10-25 ms later the action is completed successfully!

Is there a way to wait for the release of all resources (from userspace)?
