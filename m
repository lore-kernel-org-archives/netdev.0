From: Marcel Holtmann <marcel@holtmann.org>
Subject: Use CAP_NET_ADMIN and alias netdev-nlmon instead
Date: Fri, 8 Aug 2014 14:22:07 -0700
Message-ID: <7B1A5F4E-7DCD-4054-9E8C-E5511AF64CE3@holtmann.org>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:49508 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932430AbaHHVVn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2014 17:21:43 -0400
Received: from [192.168.1.123] (S010620c9d099deff.vc.shawcable.net [24.84.124.211])
	by mail.holtmann.org (Postfix) with ESMTPSA id 8973B8B30E
	for <netdev@vger.kernel.org>; Fri,  8 Aug 2014 23:21:39 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

so I am running this command sequence:

	ip link add name nlmon type nlmon
	ip link set dev nlmon up

With that I get this message in dmesg:

Loading kernel module for a network device with CAP_SYS_MODULE (deprecated). Use CAP_NET_ADMIN and alias netdev-nlmon instead.

The kernel section producing this is dev_load() from net/core/dev_ioctl.c:

        no_module = !dev;                                           
        if (no_module && capable(CAP_NET_ADMIN))                                 
                no_module = request_module("netdev-%s", name);      
        if (no_module && capable(CAP_SYS_MODULE)) {                   
                if (!request_module("%s", name))                              
                        pr_warn("Loading kernel module for a network device with CAP_SYS_MODULE (deprecated).  Use CAP_NET_ADMIN and alias netdev-%s instead.\n",
                                name);                                 
        }

Since I am explicitly giving the name from userspace, I have no idea why the kernel bugs me in providing netdev-nlmon alias. It makes no sense to me. What is the reasoning behind this?

Regards

Marcel
