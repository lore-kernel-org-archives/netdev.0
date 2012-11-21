From: Chen Gang <gang.chen@asianux.com>
Subject: [Suggestion] net/core: cpumask_scnprintf, use (PAGE_SIZE - 1) instead
 of PAGE_SIZE
Date: Wed, 21 Nov 2012 15:55:20 +0800
Message-ID: <50AC88E8.4040202@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:48707 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585Ab2KUHy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 02:54:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David Miller:

in net/core/net-sysfs.c:

  at line 496, we need use (PAGE_SIZE -1) instead of PAGE_SIZE.
  since at line 505, we append '\n'.

  regard

gchen


 479 static ssize_t show_rps_map(struct netdev_rx_queue *queue,
 480                             struct rx_queue_attribute *attribute, char *buf)
 481 {
 482         struct rps_map *map;
 483         cpumask_var_t mask;
 484         size_t len = 0;
 485         int i;
 486 
 487         if (!zalloc_cpumask_var(&mask, GFP_KERNEL))
 488                 return -ENOMEM;
 489 
 490         rcu_read_lock();
 491         map = rcu_dereference(queue->rps_map);
 492         if (map)
 493                 for (i = 0; i < map->len; i++)
 494                         cpumask_set_cpu(map->cpus[i], mask);
 495 
 496         len += cpumask_scnprintf(buf + len, PAGE_SIZE, mask);
 497         if (PAGE_SIZE - len < 3) {
 498                 rcu_read_unlock();
 499                 free_cpumask_var(mask);
 500                 return -EINVAL;
 501         }
 502         rcu_read_unlock();
 503 
 504         free_cpumask_var(mask);
 505         len += sprintf(buf + len, "\n");
 506         return len;
 507 }
 508 
