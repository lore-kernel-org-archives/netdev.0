From: Grant Likely <grant.likely@secretlab.ca>
Subject: ERR_PTR pattern in phylib
Date: Wed, 1 Sep 2010 08:42:49 -0600
Message-ID: <AANLkTimjVZTNeLdm4qptU1MqREODLASdGGanUyxqxfub@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Andy Fleming <afleming@freescale.com>,
	netdev <netdev@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:59294 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755274Ab0IAOnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 10:43:11 -0400
Received: by gwj17 with SMTP id 17so3022194gwj.19
        for <netdev@vger.kernel.org>; Wed, 01 Sep 2010 07:43:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy,

I've been looking at the phylib code, and specifically at the use of
the ERR_PTR() pattern.  I'm personally not a big fan of ERR_PTR()
because the compiler cannot type check the result and it runs
completely counter to the pattern "if (!ptr)" than is common for
testing a pointer return value.

(That being said, I do understand the need for it in certain parts of
the kernel (like the filesystem code) where it is important to be both
efficient because it is a hot path and still able to accurately return
an error code that is used by userspace.)

It seems to me that phylib is one of the cases where the users (the
network drivers) don't actually care about the specific error code
when calling phylib functions.  The drivers only seem to care whether
or not the function failed, and if it did then bail out.  I've also
noticed that using the "if (!ptr)" test on phylib return values is a
common error for driver writers.

In the interest of making driver code easier to write and review,
would you be opposed to a set of patches to remove the ERR_PTR()
pattern from phylib and its users?

g.

-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
