From: "Xiaoliang \(David\) Wei" <weixl@caltech.edu>
Subject: Re: question on routine tcp_moderate_cwnd
Date: Mon, 27 Jan 2003 14:37:13 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <001501c2c654$a395ef20$f5f2010a@weixl>
References: <20A6B72E-323D-11D7-9775-000A956767EC@lbl.gov>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Brian Tierney" <bltierney@lbl.gov>
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>, "Brian Tierney" <bltierney@lbl.gov>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Brian,
    Here's my understanding (maybe not very correct):
    When Linux tries to exit fast_recovery / loss_recovery and go back to
normal state, tcp_moderate_cwnd is applied to make sure that the cwnd would
not increase too fast from the current packet rate (packet_in_flight). This
is NOT effective during normal SlowStart/CongestionAvoid states and not
necessarily hurt the performance. If this function is deleted, there may be
a burst when Linux exit recovery.

-David

Xiaoliang (David) Wei             Graduate Student in CS@Caltech
http://www.cs.caltech.edu/~weixl
====================================================
----- Original Message -----
From: "Brian Tierney" <bltierney@lbl.gov>
To: <netdev@oss.sgi.com>
Cc: "Brian Tierney" <bltierney@lbl.gov>
Sent: Monday, January 27, 2003 1:20 PM
Subject: question on routine tcp_moderate_cwnd


> Hi all:
>
> Can someone explain what situation the routine tcp_moderate_cwnd is
> supposed to address?
>
> Im finding that this code seems to be preventing TCP for achieving
> anything close to the available bandwidth on large BDP networks.
>
> Thanks.
>
> ----------------
>
> /* CWND moderation, preventing bursts due to too big ACKs
>   * in dubious situations.
>   */
> static __inline__ void tcp_moderate_cwnd(struct tcp_opt *tp)
> {
>         u32 t = tcp_packets_in_flight(tp) + tcp_max_burst(tp);
>          if (t < tp->snd_cwnd) {
>                          tp->snd_cwnd = t;
>                          WEB100_VAR_INC(tp, OtherReductions);
>           }
>          tp->snd_cwnd_stamp = tcp_time_stamp;
> }
>
>
>
> ------------------------------------------------------------------------
> -------------------
>    Brian L. Tierney,   Lawrence Berkeley National Laboratory (LBNL)
>    1 Cyclotron Rd.  MS: 50B-2239,  Berkeley, CA  94720
>    tel: 510-486-7381    fax: 510-495-2998   efax:  240-332-4065
>    bltierney@lbl.gov   http://www-didc.lbl.gov/~tierney
> ------------------------------------------------------------------------
> ------------------
>
>
>
