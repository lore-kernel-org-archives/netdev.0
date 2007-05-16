From: Chuck Ebbert <cebbert@redhat.com>
Subject: Oops in netxen driver, kernel 2.6.20.10
Date: Wed, 16 May 2007 16:39:46 -0400
Message-ID: <464B6C12.2090706@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60258 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758331AbXEPUjt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 16:39:49 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=240190

drivers/net/netxen/netxen_nic_init.c:

                        if (ADDR_IN_WINDOW1(off)) {
                                writel(buf[i].data,
                                       NETXEN_CRB_NORMALIZE(adapter, off));
                        } else {
                                netxen_nic_pci_change_crbwindow(adapter, 0);
Line 566 ==>                    writel(buf[i].data,
                                       pci_base_offset(adapter, off));

                                netxen_nic_pci_change_crbwindow(adapter, 1);
                        }

pci_base_offset() returned NULL and the result was not checked, causing NULL
dereference.

offset is in RBX (== 0x0000000105ffffff) and is out of the expected range.

