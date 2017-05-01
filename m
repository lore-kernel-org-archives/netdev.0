From: Joe Smith <codesoldier1@gmail.com>
Subject: Question about tcp_mark_lost_retrans
Date: Mon, 1 May 2017 12:01:33 -0700
Message-ID: <CABGNecwM2eDJpPLMQZZ3DCsGDO4ktsX-R43dvgTQkd1Etq+WjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:35097 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750730AbdEATBf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 15:01:35 -0400
Received: by mail-io0-f173.google.com with SMTP id r16so128867169ioi.2
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 12:01:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the following code, write queue is traversed and ack_seq of the
skb's is used. Can someone please point out how/where it is
initialized. I can only see it being initialized in tcp_transmit_skb
but that skb will be freed since it is a clone. I could not find where
the skb queued in the write queue is initialized.

Thanks,

static void tcp_mark_lost_retrans(struct sock *sk)
{
        const struct inet_connection_sock *icsk = inet_csk(sk);
        struct tcp_sock *tp = tcp_sk(sk);
        struct sk_buff *skb;
        int cnt = 0;
        u32 new_low_seq = tp->snd_nxt;
        u32 received_upto = tcp_highest_sack_seq(tp);

        if (!tcp_is_fack(tp) || !tp->retrans_out ||
            !after(received_upto, tp->lost_retrans_low) ||
            icsk->icsk_ca_state != TCP_CA_Recovery)
                return;

        tcp_for_write_queue(skb, sk) {
                u32 ack_seq = TCP_SKB_CB(skb)->ack_seq;  <======

                if (skb == tcp_send_head(sk))
                        break;


-- 
JS
