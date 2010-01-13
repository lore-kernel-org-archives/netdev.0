From: Jiri Slaby <jirislaby@gmail.com>
Subject: qla3xxx: sleep in atomic
Date: Wed, 13 Jan 2010 13:23:41 +0100
Message-ID: <4B4DBB4D.9070807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: linux-driver@qlogic.com, netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:63257 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773Ab0AMMXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 07:23:45 -0500
Received: by fg-out-1718.google.com with SMTP id 22so175829fge.1
        for <netdev@vger.kernel.org>; Wed, 13 Jan 2010 04:23:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

stanse found a potential sleep inside atomic context. ql_sem_spinlock
must be called with hw_lock which is spinlock (locked with irq disabled
btw.), but ql_sem_spinlock calls ssleep when the HW spinlock cannot be
taken. Could you fix that somehow. E.g. unlock; sleep; lock; if not
called from irq context at all. Or alternatively lower the sleep
interval to usecs and use udelay as it seems it never trigerred (the hw
lock never failed), because people would get deadlocks otherwise.

regards,
-- 
js
