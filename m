From: "[AvataR]" <public.avatar@gmail.com>
Subject: Multthreading with netfilter?
Date: Thu, 9 Jul 2009 20:15:19 +0300
Message-ID: <d6a684ef0907091015o2d5d39f4qd38ce706b0420ab8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:59998 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753302AbZGIRPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 13:15:21 -0400
Received: by bwz25 with SMTP id 25so324571bwz.37
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2009 10:15:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I need to do difficult processing of IP packets. For speed up, I want
to process parts of packets in different kernel threads.
I start n threads (n = CPU count -1) in module initialization part,
and make them waiting (I use semaphores and self-made queue). At
nf_hook I
add tasks to queues and up() threads. As I in atomic context in
nf_iterate, I do in main thread computations, and then wait for
threads done with while() loop without scheduling. The problem is:
other threads sometimes don't wake up after up(). Sometimes, when I
press Enter key (SIC!) threads wake up, sometimes not.

Is there any right solvation for this problem?
