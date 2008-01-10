From: Jeba Anandhan <jeba.anandhan@vaioni.com>
Subject: EQL / doubts
Date: Thu, 10 Jan 2008 13:01:37 +0000
Message-ID: <1199970097.29856.21.camel@vglwks010.vgl2.office.vaioni.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vglsrv002.office.vaioni.com ([84.19.35.12]:2636 "EHLO
	vglsrv02.vgl2.office.vaioni.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755527AbYAJNDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 08:03:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,
I have few questions about EQL driver

*) Why the tx_queue_len is set as 5?.  For example if we bond 3 lines
and each has 1000 as tx_queue_len, will the bonding line(eql)
tx_queue_len be sum of these three tx_queue_len?. In this case, will the
bonding line(eql)tx_queue_len be 3000?

*)Question: Why list_add is used instead of list_add_tail?. For queue
implementation, list_add_tail would be required. Why do we implement of
slave queue in the way of stack implementation?.

 File:  linux/drivers/net/eql.c
 Function: __eql_insert_slave(slave_queue_t *queue, slave_t *slave)

Code: 

/* queue->lock must be held */

static int __eql_insert_slave(slave_queue_t *queue, slave_t *slave)
{
      if (!eql_is_full(queue)) {
           slave_t *duplicate_slave = NULL;
           duplicate_slave = __eql_find_slave_dev(queue, slave->dev);
           if (duplicate_slave != 0)
                 eql_kill_one_slave(queue, duplicate_slave);

                list_add(&slave->list, &queue->all_slaves); // Why
list_add has been
used instead of list_add_tail?. I hope queue->all_slaves is queue
implementation.

           


*) Is it possible to improve the load balancing performance using
multiprocessor?. For example,if a server has two processors and N n/w
interfaces, is it possible to assign one processor for N/2 n/w
interface's tx and rx handling and other for N/2 n/w interface's tx/rx
handling


Thanks
Jeba


