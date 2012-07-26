From: Dragos Ilie <dragos.ilie@gmail.com>
Subject: Premature timeout for MLDv1 Host compatibility mode?
Date: Thu, 26 Jul 2012 16:57:43 +0200
Message-ID: <CAOLNa-dCpLG4XCarzbSb=ptu-KGVX_Fghv4Z_CDQ8HBF_n-rGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:42983 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219Ab2GZO5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 10:57:44 -0400
Received: by obbuo13 with SMTP id uo13so2782188obb.19
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 07:57:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I suspect that the MLDv1 Host compatibility mode is ended prematurely.
In net/ipv6/mcast.c the "Older Version Querier Present" timeout is
computed as

max_delay = (ntohs(mld->mld_maxdelay)*HZ)/1000;
switchback = (idev->mc_qrv + 1) * max_delay;
idev->mc_v1_seen = jiffies + switchback;


RFC 3810 says that the timeout should be computed as
Robustness_Variable * Query_Interval + Query_Response_Interval. This
suggests that the line where switchback is computed should be changed
to something like

switchback = (idev->mc_qrv * 125 * HZ)  + max_delay;

where 125 is the default Query_Interval in seconds

I would appreciate it if somebody can confirm if my suspicion is correct.

Regards,
Dragos
