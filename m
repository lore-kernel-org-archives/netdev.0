From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCHv2 net-next 0/4] MTU changes and other fixes
Date: Thu, 7 Jan 2016 21:50:11 +0000
Message-ID: <20160107215011.607779cc@jkicinski-Precision-T1700>
References: <1451995051-21920-1-git-send-email-jakub.kicinski@netronome.com>
	<20160107.145750.213741381921685070.davem@davemloft.net>
	<20160107204928.0cd91c16@jkicinski-Precision-T1700>
	<20160107.163314.666536912327323086.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
	rolf.neugebauer@netronome.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35128 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230AbcAGVuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 16:50:16 -0500
Received: by mail-wm0-f47.google.com with SMTP id f206so114012697wmf.0
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 13:50:16 -0800 (PST)
In-Reply-To: <20160107.163314.666536912327323086.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 07 Jan 2016 16:33:14 -0500 (EST), David Miller wrote:
> From: Jakub Kicinski <jakub.kicinski@netronome.com>
> Date: Thu, 7 Jan 2016 20:49:28 +0000
> 
> > I know this is not what you asked for but, since we are using FW
> > commands to disable/enable RX, even if we allocate all required
> > resources before freeing old ones we still cannot guarantee that
> > the reenabling operation will not fail.  Should we refuse to do
> > MTU changes while the interface is running altogether?
> 
> If you issue the MTU change command and it fails, then you're still
> configured at the old MTU.  There should therefore be no problem
> rewinding in that case.

No, no...  The FW command is to stop and start the RX path in
the NIC.  Our NIC is NPU-based, it has a ton of programmability
so even though we try to make it work like a run-of-the-mill
NIC there are some gotchas.

Unless there is a way to change MTU without stopping RX which
escapes me.

> > All drivers I've seen ...
> 
> Bad practice in other drivers should be ignored, not copied.

I'll take that to heart.
