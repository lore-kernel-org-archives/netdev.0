From: "Amar Mudrankit" <amar.mudrankit@gmail.com>
Subject: NAPI: Poll is not getting invoked.
Date: Thu, 24 Jul 2008 12:07:44 +0530
Message-ID: <c8028d330807232337i7c3fb923q68a7e8b258945b78@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:29407 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996AbYGXGhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 02:37:45 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2733083rvb.1
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2008 23:37:44 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During the experimentation of NAPI on ethernet driver, the poll
function registered for the driver is not getting invoked, though it
was scheduled successfully.
In the interrupt handler function when packet is received, I have
scheduled a poll using:

netif_rx_schedule();

The control is reaching this function and executing
netif_rx_schedule() which was verified by putting some debug printk
statements in code. But, initial printk statement in the "poll " is
not getting printed, which indicates that poll function is not getting
invoked.

During alloc_netdev, I have registered the poll function for my net_device:

netif_napi_add();

and enabled it using:

napi_enable();

during the call to dev->open().

Am I missing something in the NAPI process? Can somebody please point
out the things that I can try to debug this issue?

Regards,
Amar
