From: Jan-Philip gehrcke <jgehrcke@googlemail.com>
Subject: Read sent/received bytes -- without opening a file in /sys or /proc
Date: Thu, 17 Feb 2011 11:57:29 +0100
Message-ID: <4D5CFF19.6050400@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:65115 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020Ab1BQK5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 05:57:32 -0500
Received: by fxm20 with SMTP id 20so2449033fxm.19
        for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 02:57:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear list,

I'm about to write a small C program for measurements of the bandwidth
on some network interface of my home router (uname -a: Linux
fritz.fonwlan.box 2.6.19.2 #2 Thu Nov 18 16:35:17 CET 2010 mips
GNU/Linux). I would like to accomplish very *precise* results, while
keeping the absolute measurement time low.

In general, this problem requires the knowledge of time and byte
differences. Therefore, two time measurements and two byte counter
measurements for each, received and sent bytes, are required. Currently,
I am measuring time via

    clock_gettime(CLOCK_MONOTONIC, ...)

and reading the byte counters by reading files in sysfs, e.g.

     /sys/class/net/${interface}/statistics/rx_bytes.

This is very easy and works well, but reading these files four times
takes some (varying) time* on my device, which introduces an error to my
calculation.

Hence, I am wondering, if there is a way to receive this kind of data
directly and much faster, via "kernel API". My question is related to
this unanswered one from 2005:
http://linux.derkeiler.com/Mailing-Lists/RedHat/2005-02/0557.html

*On my device, reading such a file and interpreting the result as
integer takes 1-10 ms, measured via:

    clock_gettime(CLOCK_MONOTONIC, &t_start);
    rx_bytes = read_int_from_file("/sys/class/net/wan/statistics/rx_bytes");
    clock_gettime(CLOCK_MONOTONIC, &t_end);

read_int_from_file() basically consists of fopen(), fgets(), and sscanf().


Please note that I don't have kernel/driver programming experience so far.

Thank you for help and any suggestions!

    Jan-Philip Gehrcke

--
http://gehrcke.de
