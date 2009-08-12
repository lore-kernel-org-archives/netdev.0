From: =?UTF-8?B?7ZmN7IugIHNoaW4gaG9uZw==?= <hongshin@gmail.com>
Subject: net/unix : possible race bug at unix_create1()
Date: Thu, 13 Aug 2009 00:00:22 +0900
Message-ID: <2014bcab0908120800v77e3a91dy82601ee9f536035d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f191.google.com ([209.85.211.191]:35776 "EHLO
	mail-yw0-f191.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753372AbZHLPAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 11:00:22 -0400
Received: by ywh29 with SMTP id 29so87186ywh.33
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2009 08:00:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi. I am reporting a possible race bug at unix_create1()
in net/unix/af_unix.c of Linux 2.6.30.4.

Concurrent executions of unix_create1() function
in two different threads may result race condition
when unix_nr_socks +1 == 2 * get_max_files().

It is possible that no thread can pass the if-condition
checking if two atomic_inc() operations are executed
before.

It seems that it would be better to combine two
atomic operations into one atomic_inc_and_return().

Please examine the code and let me know your opinion.

Thank you

Sincerely
Shin Hong
