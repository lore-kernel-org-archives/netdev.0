From: Ivan Novick <novickivan@gmail.com>
Subject: Choppy TCP send performance
Date: Fri, 28 May 2010 13:38:53 -0700
Message-ID: <AANLkTilSrX5PifVHlxMjTK-wo_viD8IS_1m1k-vPOlE3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Tim Heath <theath@greenplum.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:62417 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753151Ab0E1Uiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 16:38:55 -0400
Received: by vws9 with SMTP id 9so1472658vws.19
        for <netdev@vger.kernel.org>; Fri, 28 May 2010 13:38:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am using RHEL5 and have 1 Gigabit NIC cards.

When doing a loop sending 128 KB blocks of data using TCP.  I am using
system tap to debug the performance and finding that:

90% of the send calls take about 100 micro seconds and 10% of the send
calls take about 10 miliseconds.  The average send time is about 1
milisecond

The 10% of the calls taking about 10 milliseconds seem to be
correlated with "sk_stream_wait_memory" calls in the kernel.

sk_stream_wait_memory seems to be called when the send buffer is full
and the next send call does not complete until the send buffer
utilization goes down from 4,194,304 bytes to 2,814,968 bytes.

This implies that the send that blocks on a full send buffer will not
complete until there is 1 meg of free space in the send buffer even
though the send could be accepted into the OS with only 128KB of free
space.

Do you think I am misinterpreting this data or is there a way to even
out the send calls so that they they are more even in duration: approx
1 milisecond per call.  Is there a parameter to reduce how much space
needs to be free in the send buffer before a blocking send call can
complete from user space?

Cheers,
Ivan
