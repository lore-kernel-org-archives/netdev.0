From: Anton Blanchard <anton@samba.org>
Subject: ehea work queues
Date: Sun, 30 Sep 2007 11:20:19 -0500
Message-ID: <20070930162019.GE28619@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: themann@de.ibm.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:36266 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753505AbXI3QWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Sep 2007 12:22:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

I booted 2.6.23-rc8 and noticed that ehea loves its workqueues:

# ps aux|grep ehea
root      3266  0.0  0.0    0    0 ?    S<   11:02   0:00 [ehea_driver_wq/]
root      3268  0.0  0.0    0    0 ?    S<   11:02   0:00 [ehea_driver_wq/]
root      3269  0.0  0.0    0    0 ?    S<   11:02   0:00 [ehea_driver_wq/]
root      3270  0.0  0.0    0    0 ?    S<   11:02   0:00 [ehea_driver_wq/]
root      3271  0.0  0.0    0    0 ?    S<   11:02   0:00 [ehea_driver_wq/]
root      3272  0.0  0.0    0    0 ?    S<   11:02   0:00 [ehea_driver_wq/]
root      3273  0.0  0.0    0    0 ?    S<   11:02   0:00 [ehea_driver_wq/]
root      3274  0.0  0.0    0    0 ?    S<   11:02   0:00 [ehea_driver_wq/]
root      3275  0.0  0.0    0    0 ?    S<   11:02   0:00 [ehea_wq/0]
root      3276  0.0  0.0    0    0 ?    S<   11:02   0:00 [ehea_wq/1]
root      3278  0.0  0.0    0    0 ?    S<   11:02   0:00 [ehea_wq/2]
root      3279  0.0  0.0    0    0 ?    S<   11:02   0:00 [ehea_wq/3]
root      3280  0.0  0.0    0    0 ?    S<   11:02   0:00 [ehea_wq/4]
root      3281  0.0  0.0    0    0 ?    S<   11:02   0:00 [ehea_wq/5]
root      3282  0.0  0.0    0    0 ?    S<   11:02   0:00 [ehea_wq/6]
root      3283  0.0  0.0    0    0 ?    S<   11:02   0:00 [ehea_wq/7]

(notice also that the ehea_driver_wq/XXX exceeds TASK_COMM_LEN). 

Since they are both infrequent events and not performance critical
(memory hotplug and driver reset), can we just use schedule_work?

Anton
