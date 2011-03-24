From: Guillaume Leclanche <guillaume@leclanche.net>
Subject: Need a special way tune TCP IPv6->IPv4 fallback timeout
Date: Thu, 24 Mar 2011 17:23:15 +0100
Message-ID: <AANLkTikP7AFMnQ4BdnE2272zNupv_ysb3BDWTqy=9s34@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:43992 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932660Ab1CXQXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 12:23:35 -0400
Received: by iwn34 with SMTP id 34so94556iwn.19
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2011 09:23:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

(this is a copy of text I've put in
https://bugzilla.kernel.org/show_bug.cgi?id=23242 for anyone who would
like to do something with bugzilla).

When applications call the connect() API, if AAAA record is returned
and correct routing is present, the system will start a TCP connection
over IPv6.
However, if the host is finally unreachable, the system waits until
the IPv6 TCP connection attempt fails, that is roughly 3 min (5
retries, backoff, well, you know that). Then it falls back to IPv4.

Afaik, the only way to tune this timeout of 3 mins in the kernel is
the tcp_syn_retries sysctl (RTO tuning not available in Linux TCP). By
setting the value to 2, you can reduce the delay to ~10s which is more
acceptable, and still 3 SYN are sent.

In order not to modify uselessly the TCP parameters for standard
IPv4-only connections at the same time, it would be necessary to have
a *separate* parameter-set to decrease the v6->v4 fallback delay.

No idea how feasible this is, nor if it has already been discussed
here in the past.

// Not subscribed, please CC me.

Best regards,
Guillaume
