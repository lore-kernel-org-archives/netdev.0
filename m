From: "Tom Herbert" <therbert@google.com>
Subject: HW queuing and QoS
Date: Tue, 20 Nov 2007 16:47:45 -0800
Message-ID: <65634d660711201647t6e9541f4w3760bd99e2c8c0fd@mail.gmail.com>
References: <65634d660711201641y1e56e97bjcf86f121246e35bb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:38893 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765398AbXKUArz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 19:47:55 -0500
Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id lAL0lnkC014784
	for <netdev@vger.kernel.org>; Tue, 20 Nov 2007 16:47:49 -0800
Received: from rv-out-0910.google.com (rvfc27.prod.google.com [10.140.180.27])
	by zps77.corp.google.com with ESMTP id lAL0lkY5003761
	for <netdev@vger.kernel.org>; Tue, 20 Nov 2007 16:47:46 -0800
Received: by rv-out-0910.google.com with SMTP id c27so1663229rvf
        for <netdev@vger.kernel.org>; Tue, 20 Nov 2007 16:47:45 -0800 (PST)
In-Reply-To: <65634d660711201641y1e56e97bjcf86f121246e35bb@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

We've been working with the e1000 driver and applying the various
queuing disciplines.  I've noticed that the effectiveness of the work
conserving queuing disciplines, such as priority queues, diminishes as
more packets are queued to hardware ( i.e. high priority packets
suffer from HOLB).  Reducing the TX descriptor limits helps QoS
properties, but risks starving the transmitter when sending small
packets.

To address this we've been experimenting with limiting the amount of
data in the HW queue by number of bytes.  The idea would be that we
dynamically compute the minimum number of bytes needed to be queued to
prevent the hardware queue from starving, thus minimizing latency in
the queue and improving the useful of the queuing disciplines.

Has anyone contemplated this or tried something similar?

Thanks,
Tom
