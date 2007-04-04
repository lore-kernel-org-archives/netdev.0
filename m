From: "Gagan Arneja" <gaagaan@gmail.com>
Subject: tg3 reset_task question
Date: Wed, 4 Apr 2007 13:34:12 -0700
Message-ID: <d66d623f0704041334m5e0c68ebw777f621c779e1153@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:49425 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbXDDUeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 16:34:19 -0400
Received: by ug-out-1314.google.com with SMTP id 44so798806uga
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2007 13:34:13 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Can't this BUG_ON be hit very easily:

static void tg3_irq_quiesce(struct tg3 *tp)
{
        BUG_ON(tp->irq_sync);
...
}

tg3_reset_task could easily be racing with another thread, that calls
tg3_full_lock(tp, 1); e.g tg3_change_mtu. Maybe I'm missing something
obvious.

--
Gagan
