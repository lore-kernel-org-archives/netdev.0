From: Nicholas Van Orton <turanammo@gmail.com>
Subject: e100 skb allocation
Date: Wed, 24 Jun 2009 14:19:48 +0530
Message-ID: <b9e8fcbd0906240149g2f2e18f2vcd7dce234c949564@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:47150 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755995AbZFXItp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 04:49:45 -0400
Received: by rv-out-0506.google.com with SMTP id f6so167961rvb.1
        for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 01:49:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

	For the Intel 8256 Ethernet Controller (e100.c), I notice that at the
time of skb allocation using netdev_alloc_skb() and just before
calling skb_reserve(), rx->skb->head and rx->skb->tail do not point to
the same location. In fact they are already 16bytes apart. After
calling  skb_reserve(), which would add a 2 byte padding, head and
tail would be 18 bytes apart. Is this behaviour correct? Shouldn't the
ethernet header be 14+2 bytes after padding? Why aren't head and tail
at the same location at the beginning?


Thanks and regards,
Nicholas
