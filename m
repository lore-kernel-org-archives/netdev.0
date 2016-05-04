From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: ensure non-empty connection request queue
Date: Wed, 04 May 2016 11:18:25 -0700
Message-ID: <1462385905.5535.352.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1462312458-2077-1-git-send-email-peter@lekensteyn.nl>
	 <1462321544.5535.337.camel@edumazet-glaptop3.roam.corp.google.com>
	 <572A3048.60802@hpe.com>
	 <1462383266.5535.350.camel@edumazet-glaptop3.roam.corp.google.com>
	 <572A39E6.1020001@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter Wu <peter@lekensteyn.nl>,
	"David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Kui Zhang <kuizhang@gmail.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33149 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753596AbcEDSS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 14:18:28 -0400
Received: by mail-pf0-f182.google.com with SMTP id 206so28132312pfu.0
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 11:18:28 -0700 (PDT)
In-Reply-To: <572A39E6.1020001@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-05-04 at 11:05 -0700, Rick Jones wrote:

> Assuming Peter's assertion about just drops when syncookies are not 
> enabled is accurate, should there be some one-time message in that case too?

We have plenty of drop points in the kernel without a message in syslog,
but proper SNMP counter updates.

Look at my recent commit 
9caad864151e525 ("tcp: increment sk_drops for listeners")

"ss -tm state listening" will show you the drop count per listener.
