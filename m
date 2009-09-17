From: hong liu <hong.liu96@gmail.com>
Subject: question about tcp_ack_update_window
Date: Thu, 17 Sep 2009 11:24:03 +0800
Message-ID: <204986780909162024s785004e3q319f1b85c68f66@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.211.175]:49262 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752628AbZIQDYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 23:24:00 -0400
Received: by ywh5 with SMTP id 5so8276947ywh.4
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2009 20:24:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In tcp_ack_update_window, we don't scale the window if it's a SYN packet.
This modification is introduced by Kevin Lahey during 2.5.75
(http://oss.sgi.com/archives/netdev/2003-10/msg01391.html).

tcp_ack_update_window is only called by tcp_ack, which is called by
tcp_rcv_synsent_state_process & tcp_rcv_established, and we change the
snd_wnd back to th->window in tcp_rcv_synsent_state_process, so why we
still need this  check in tcp_ack_update_window?

I think we may need to add tp->max_window = tp->snd_wnd in
tcp_rcv_syssent_state_process if we remove the check in tcp_ack_update_window.

The only problem I can see is: client entered into established state and sent
an ack (the last packet in 3-way handershake) to the server, but the packet
got lost / arrived slightly late. Then server resent a SYN+ACK packet,
then client can get a SYN packet and call tcp_ack in tcp_rcv_established.

Is this the only concern?

Thanks,
Hong
