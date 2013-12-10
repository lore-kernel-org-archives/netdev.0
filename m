From: ajay seshadri <seshajay@gmail.com>
Subject: Fwd: UDP/IPv6 performance issue
Date: Tue, 10 Dec 2013 11:19:29 -0500
Message-ID: <CAGA2gK5gfdaKeQWzT4Dd45AhavD4pYaCVyayf7Hd+q5pPUjfKQ@mail.gmail.com>
References: <CAGA2gK6rf8E7cCO=RwbdFAt2ucfxUbCjqhVoga9cnHrEKxcp9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:57709 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753904Ab3LJQT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 11:19:29 -0500
Received: by mail-ie0-f171.google.com with SMTP id ar20so8991474iec.16
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 08:19:29 -0800 (PST)
In-Reply-To: <CAGA2gK6rf8E7cCO=RwbdFAt2ucfxUbCjqhVoga9cnHrEKxcp9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have been testing network performance using my application and other
third party tools like netperf on my systems that have 10G NIC Cards.
It's a simple back to back setup with no switches in between.

I see about 15 to 20% performance degradation for UDP/IPv6 as compared
to UDP/IPv4 for packets of size 1500.

On performing "perf top" analysis for ipv6 traffic, I identified the
following functions as some hot functions:
fib6_force_start_gc()
csum_partial_copy_generic()
udp_v6_flush_pending_frames()
dst_mtu()

csum_partial_copy_generic() shows up because my card doesn't support
checksum offloading for ipv6 packets. In fact turning off rx / tx
checksum offloading for ipv4 showed the same function in the "perf
top" profile, but did not cause any performance degradation.

Now I am CPU bound on packets of size 1500 and I am not using GSO (for
both IPv4 and IPv6). I tried twiddling with the route cache garbage
collection timer values and tried to set the socket options to disable
pmtu discovery and set the mtu for the socket, but it did not make any
difference.

I am wondering if this is a known performance issue or can I fine tune
the system to match UDP / IPv4 performance with UDP / IPv6? As I am
CPU bound, the functions I identified are using up CPU cycles that i
could probably save.

Any help is appreciated.

Thanks,
Ajay
