From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Force ACK each received tcp segment under no condition
Date: Fri, 24 Jan 2014 15:18:19 -0800
Message-ID: <CAK3+h2wd5gEp9oDMZpte-Ed2M3eGSzdkuMJuvk24p=9JcjAzAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:37627 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751282AbaAXXSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jan 2014 18:18:21 -0500
Received: by mail-ob0-f175.google.com with SMTP id wn1so4307925obc.34
        for <netdev@vger.kernel.org>; Fri, 24 Jan 2014 15:18:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I know this sounds really silly, but I would like to do such test to
meet my curiosity. is that all I need to do?

static void __tcp_ack_snd_check(struct sock *sk, int ofo_possible)
{
        struct tcp_sock *tp = tcp_sk(sk);

            /* More than one full frame received... */
        if (((tp->rcv_nxt - tp->rcv_wup) > inet_csk(sk)->icsk_ack.rcv_mss
             /* ... and right edge of window advances far enough.
              * (tcp_recvmsg() will send ACK otherwise). Or...
              */
             && __tcp_select_window(sk) >= tp->rcv_wnd) ||
            /* We ACK each frame or... */
            tcp_in_quickack_mode(sk) ||
            /* We have out of order data. */
            (ofo_possible && skb_peek(&tp->out_of_order_queue))) {
                /* Then ack it now */
                tcp_send_ack(sk);
        } else {
                /* Else, send delayed ack. */
                //tcp_send_delayed_ack(sk);
                 tcp_send_ack(sk);

        }
}
