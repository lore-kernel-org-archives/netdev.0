From: Steve Fink <sphink@gmail.com>
Subject: ss -p is much too slow
Date: Wed, 9 Jun 2010 11:42:38 -0700
Message-ID: <AANLkTikd3VaSUa-pxzyi7_fND40vQ-L79X7yv19jj3y0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:46092 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758067Ab0FISmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 14:42:39 -0400
Received: by yxl31 with SMTP id 31so1164979yxl.19
        for <netdev@vger.kernel.org>; Wed, 09 Jun 2010 11:42:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was recently working with a monitoring system, and one check
involved displaying what process(es) were listening on specific ports.
I was using a single call to ss -lntp and processing the output, but
it would often take several minutes to respond. netstat -lntp, on the
other hand, was immediate. I had a few thousand processes running on
the machine, and it could take 7 minutes or so.

On closer inspection, it appears that ss -p does a quadratic scan. It
rescans every entry in /proc/*/fd/* repeatedly (once per listening
port? per process? I don't remember what I figured out.)

I humbly suggest that this is not a good idea.

I am currently running iproute-2.6.27-2.fc10.i386, though my real test
case was on a different machine. I don't have a newer version to check
right now.

% strace ss -lntp |& fgrep /proc/3768/fd/10
readlink("/proc/3768/fd/10", "socket:[16214]"..., 63) = 14
readlink("/proc/3768/fd/10", "socket:[16214]"..., 63) = 14
readlink("/proc/3768/fd/10", "socket:[16214]"..., 63) = 14
readlink("/proc/3768/fd/10", "socket:[16214]"..., 63) = 14
readlink("/proc/3768/fd/10", "socket:[16214]"..., 63) = 14
readlink("/proc/3768/fd/10", "socket:[16214]"..., 63) = 14
readlink("/proc/3768/fd/10", "socket:[16214]"..., 63) = 14
readlink("/proc/3768/fd/10", "socket:[16214]"..., 63) = 14
readlink("/proc/3768/fd/10", "socket:[16214]"..., 63) = 14
readlink("/proc/3768/fd/10", "socket:[16214]"..., 63) = 14
readlink("/proc/3768/fd/10", "socket:[16214]"..., 63) = 14
readlink("/proc/3768/fd/10", "socket:[16214]"..., 63) = 14
readlink("/proc/3768/fd/10", "socket:[16214]"..., 63) = 14
readlink("/proc/3768/fd/10", "socket:[16214]"..., 63) = 14
readlink("/proc/3768/fd/10", "socket:[16214]"..., 63) = 14
readlink("/proc/3768/fd/10", "socket:[16214]"..., 63) = 14
readlink("/proc/3768/fd/10", "socket:[16214]"..., 63) = 14
readlink("/proc/3768/fd/10", "socket:[16214]"..., 63) = 14
