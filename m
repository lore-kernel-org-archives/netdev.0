From: "John Zeng" <zrzeng@linuxforum.net>
Subject: Please help, Two simple questions regarding Linux TCP codes
Date: Fri, 29 Aug 2003 16:34:06 +0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <001901c36e08$4fa4cce0$0301a8c0@homepc>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, all,

I am a pretty newbie in Linux TCP codes,
now I know the overall operation of the Linux TCP codes,
but some details has really confused me for a long time,
would anyone there please kindly help me? thank you very much.

-------------------------------------
Q.1) in tcp_input.c, there is a function called tcp_check_reno_reordering(),
   as following:
static void tcp_check_reno_reordering(struct tcp_opt *tp, int addend)
{
    u32 holes;

    holes = max(tp->lost_out, 1U);
    holes = min(holes, tp->packets_out);

    if (tp->sacked_out + holes > tp->packets_out) {
        tp->sacked_out = tp->packets_out - holes;
        tcp_update_reordering(tp, tp->packets_out+addend, 0);
    }
}

In my imagination, only when segments are duplicated in the network,
will the statement "tp->sacked_out + holes > tp->packets_out" be true.
but because the function name shows that it is related to reordering,
I must have missed some important points,
could you please tell me what is the situation? i.e. in what reordering
circumstances will "tp->sacked_out + holes > tp->packets_out" be true?
-------------------------------

Q.2)what is the rationale behind of the function _tcp_grow_window()?
  to be more specific, what is the rationale of the while loop?
  i.e. why can we judge that when "truesize <= skb->len" is true,
  we can increase the window by 2*tp->ack.rcv_mss?

static int __tcp_grow_window(struct sock *sk, struct tcp_opt *tp, struct
sk_buff *skb)
{
    /* Optimize this! */
    int truesize = tcp_win_from_space(skb->truesize)/2;
    int window = tcp_full_space(sk)/2;

    while (tp->rcv_ssthresh <= window) {
        if (truesize <= skb->len)
            return 2*tp->ack.rcv_mss;

        truesize >>= 1;
        window >>= 1;
    }
    return 0;
}
