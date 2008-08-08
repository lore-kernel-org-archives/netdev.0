From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: Strange tg3 regression with UMP fw. link reporting
Date: Fri, 8 Aug 2008 10:58:58 +0200
Message-ID: <31233EB5-037E-4615-95C9-7C816E510752@kernel.crashing.org>
References: <1218180939.24157.332.camel@pasglop>
Mime-Version: 1.0 (Apple Message framework v753.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	netdev <netdev@vger.kernel.org>, Nathan Lynch <ntl@pobox.com>,
	Michael Chan <mchan@broadcom.com>
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:41694 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042AbYHHI72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 04:59:28 -0400
In-Reply-To: <1218180939.24157.332.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I don't know yet for sure what happens, but a quick look at the commit
> seems to show that the driver synchronously spin-waits for up to 2.5ms

That's what the comment says, but the code says 2.5 _seconds_:

+       /* Wait for up to 2.5 milliseconds */
+       for (i = 0; i < 250000; i++) {
+               if (!(tr32(GRC_RX_CPU_EVENT) & GRC_RX_CPU_DRIVER_EVENT))
+                       break;
+               udelay(10);
+       }

(not that milliseconds wouldn't be bad already...)


Segher

