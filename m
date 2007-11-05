From: Chuck Ebbert <cebbert@redhat.com>
Subject: netfilter: nf_conntrack_ipv4 does not show nf_nat as a user
Date: Mon, 05 Nov 2007 15:10:49 -0500
Message-ID: <472F78C9.9060900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60400 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752045AbXKEUKv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2007 15:10:51 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id lA5KAolU025283
	for <netdev@vger.kernel.org>; Mon, 5 Nov 2007 15:10:50 -0500
Received: from mail.boston.redhat.com (mail.boston.redhat.com [172.16.76.12])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id lA5KAnnq024302
	for <netdev@vger.kernel.org>; Mon, 5 Nov 2007 15:10:49 -0500
Received: from [172.16.83.145] (dhcp83-145.boston.redhat.com [172.16.83.145])
	by mail.boston.redhat.com (8.13.1/8.13.1) with ESMTP id lA5KAn8t023453
	for <netdev@vger.kernel.org>; Mon, 5 Nov 2007 15:10:49 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

https://bugzilla.redhat.com/show_bug.cgi?id=333481#c3

This is netfilter kernel problem. There is a usage count for the conntrack_ipv4
module from the nf_nat module, which is not reported by lsmod.

How to reproduce:
# modprobe nf_conntrack_ipv4
# lsmod | grep nf_conntrack_ipv4
nf_conntrack_ipv4      11717  0 
nf_conntrack           51977  2 nf_conntrack_ipv4,nf_conntrack_ipv6
nfnetlink               8281  3 nf_conntrack_ipv4,nf_conntrack_ipv6,nf_conntrack
# modprobe nf_nat
# lsmod | grep nf_conntrack_ipv4
nf_conntrack_ipv4      11717  1 
nf_conntrack           51977  3 nf_nat,nf_conntrack_ipv4,nf_conntrack_ipv6
nfnetlink               8281  4 nf_nat,nf_conntrack_ipv4,nf_conntrack_ipv6,nf_co
nntrack
# lsmod | grep nf_nat
nf_nat                 18669  0 
nf_conntrack           51977  3 nf_nat,nf_conntrack_ipv4,nf_conntrack_ipv6
nfnetlink               8281  4 nf_nat,nf_conntrack_ipv4,nf_conntrack_ipv6,nf_co
nntrack
# rmmod nf_conntrack_ipv4
ERROR: Module nf_conntrack_ipv4 is in use
# rmmod nf_nat
# rmmod nf_conntrack_ipv4
