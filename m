From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: net: return actual error on register_queue_kobjects
Date: Fri, 20 Jun 2014 00:28:40 +0300
Message-ID: <20140619212840.GA15522@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jeff.liu@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:29062 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964833AbaFSV26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2014 17:28:58 -0400
Received: from ucsinet21.oracle.com (ucsinet21.oracle.com [156.151.31.93])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id s5JLSvVL028467
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 19 Jun 2014 21:28:58 GMT
Received: from userz7022.oracle.com (userz7022.oracle.com [156.151.31.86])
	by ucsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id s5JLSvYb020872
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 19 Jun 2014 21:28:57 GMT
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by userz7022.oracle.com (8.14.5+Sun/8.14.4) with ESMTP id s5JLSt3T011503
	for <netdev@vger.kernel.org>; Thu, 19 Jun 2014 21:28:56 GMT
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jie Liu,

The patch d36a4f4b4723: "net: return actual error on
register_queue_kobjects" from Jun 17, 2014, leads to the following
static checker warning:

	net/core/net-sysfs.c:1203 register_queue_kobjects()
	warn: 'net->queues_kset' isn't an ERR_PTR

net/core/net-sysfs.c
  1200  #ifdef CONFIG_SYSFS
  1201          net->queues_kset = kset_create_and_add("queues",
                                   ^^^^^^^^^^^^^^^^^^^
This function returns a NULL on error doesn't it?  In linux-next it
does.  The patch description is not clear.

  1202              NULL, &net->dev.kobj);
  1203          if (IS_ERR(net->queues_kset))
  1204                  return PTR_ERR(net->queues_kset);
  1205          real_rx = net->real_num_rx_queues;
  1206  #endif

regards,
dan carpenter
