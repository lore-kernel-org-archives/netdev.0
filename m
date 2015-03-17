From: Richard Cochran <richardcochran@gmail.com>
Subject: Configuring synchronous ethernet with ethtool?
Date: Tue, 17 Mar 2015 17:11:28 +0100
Message-ID: <20150317161128.GA8793@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:34255 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753451AbbCQQLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 12:11:33 -0400
Received: by wegp1 with SMTP id p1so11482113weg.1
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 09:11:32 -0700 (PDT)
Received: from localhost.localdomain (88-117-31-137.adsl.highway.telekom.at. [88.117.31.137])
        by mx.google.com with ESMTPSA id ax10sm20547980wjc.26.2015.03.17.09.11.30
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 17 Mar 2015 09:11:31 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear list,

I need to configure Synchronous Ethernet (SyncE) on a per-port basis
for a current project.  So, I have been thinking about how best to
implement SyncE.  My first idea is to make this into a new ethtool
operation, but I would like to get some feedback about the direction.

Apart from ITU-T G.8261, 8262, and 8264, which are not too helpful, I
could hardly find any documentation at all about how SyncE is supposed
to work.  My current understanding is limited to:

* 100 Mbit

  - Each link partner generates its own transmit clocks.

  - There is at least one 100 Mbit PHY that allows using the recovered
    clock from the link partner for the PHY's own transmit clock.
    (SyncE slave mode)

* 1000 Mbit

  - With 1000 Mbit, only one of the link partners generates a
    clock. The decision of which link partner becomes the clock master
    is a normal part of the Gigabit protocol.

  - One switch I have worked with has per-port bits that allow setting
    MASTER/SLAVE and MANUAL/PREFERRED.  I am not sure what the
    "preferred" modes does.

So, my current idea is to have an ethtool option to set the SyncE mode
to one of:

- master (1000 Mbit only)
- slave
- none

I am not sure whether the manual/preferred thing makes any sense.
Maybe someone has insight into this?

Thoughts?

Thanks,
Richard
