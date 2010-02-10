From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 0/5] sky2: Avoid down and up during sky2_reset
Date: Wed, 10 Feb 2010 23:11:43 +0900
Message-ID: <4B72BE9F.2000602@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f187.google.com ([209.85.222.187]:55858 "EHLO
	mail-pz0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914Ab0BJORA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 09:17:00 -0500
Received: by pzk17 with SMTP id 17so24824pzk.4
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 06:16:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Stephen,

This patch set reimplements sky2_reset so that 

 * interrupts are disabled during reset
 * memory is not free'd and reallocated
 * tx queues are stopped during reset, but the device is not brought down

Additionally, it avoids partial initialization of the hardware when ring buffer allocation fails.

The rx ring still needs to be fully allocated for sky2_up to succeed.

thanks,

Mike

