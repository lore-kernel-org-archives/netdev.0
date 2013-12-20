From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Excessive IPI interrupts with single RX queue devices and rps_cpus
 mask set
Date: Thu, 19 Dec 2013 17:12:17 -0800
Message-ID: <CAGVrzcawQhyMXw+_0394OJ=UfiN1Lyxf+JThYPbWrJM6LSZ-WA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>, therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:50536 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756516Ab3LTBM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 20:12:57 -0500
Received: by mail-pd0-f172.google.com with SMTP id g10so1843770pdj.17
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 17:12:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

After configuring the rps_cpus mask to enable all CPUs for a single RX
queue network device, I noticed that I was getting one interrupt per
packet received, with the interrupt count being splitted between NAPI
interrupts and IPI SMP interrupts.

This behavior was observed on 3.8.13 as well as 3.3. The host was
receiving a Gigabit UDP stream and the receiver was not consuming the
SKBs. Whenever there was a listener consuming the SKBs received, the
number of IPI/sec quickly jumped to about 4 times the number without a
rps_cpus mask.

Shall we prevent the rps_cpu mask to be set at all for single RX queue
devices since this seems to causes excessive IPI interrupts?
-- 
Florian
