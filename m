From: Ashoka K <ashok.vinu@gmail.com>
Subject: Tuning TCP send on ethernet
Date: Wed, 8 Apr 2015 16:51:48 +0530
Message-ID: <CALJd4cZpffegZ7RQ_QkRbbeQDUpUwK1peYe14PxpgZkbwsfUCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:33961 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753916AbbDHLVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 07:21:49 -0400
Received: by qkgx75 with SMTP id x75so81181653qkg.1
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 04:21:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi ,

I have a question regarding TCP send queue on ethernet 100Mbps line.
If you could answer it would be of great help.

We have a Linux based ARM system. Basically it capture image and
transfer images on request to a windows client. During image transfer
the softirq are seen in high number. These softirq are from network
device which transfer image data. Due to this we see that other
processes got hit in performance. For us the priority for sending the
image data is low and we expect that this send should not block or
slow down other running processes in system.

The image data is sent on particular TCP port say 2000. Only this
transfer of image traffic has to be slowed/or whatever so that this
does not affect other processes running on device. The maximum size of
image is only 1.4 MB.

There is other less TCP traffic on other ports. These traffic include
the commands sent to the device and command responses. This must not
be affected severely.

 How to tune this? Device uses Linux 2.6.33 cross compiled for ARM,
and it has 1 ethernet interface of speed 100Mbps, has 1GHz CPU.

I tried to modify ethernet "txqueuelen" from default 1000  to  a min
of 1 to a max of 8000. But i didn't see improvement in behavior.

DO I have to modify  /kernel/softirq.c:

   #define     MAX_SOFTIRQ_RESTART  10

to smaller value ? What effects it may have? Or any other better solutions?

Regards,
Ashoka
