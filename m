From: Brian Tierney <bltierney@lbl.gov>
Subject: question on routine tcp_moderate_cwnd
Date: Mon, 27 Jan 2003 13:20:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20A6B72E-323D-11D7-9775-000A956767EC@lbl.gov>
Mime-Version: 1.0 (Apple Message framework v551)
Content-Type: text/plain; delsp=yes; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brian Tierney <bltierney@lbl.gov>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all:

Can someone explain what situation the routine tcp_moderate_cwnd is  
supposed to address?

Im finding that this code seems to be preventing TCP for achieving  
anything close to the available bandwidth on large BDP networks.

Thanks.

----------------

/* CWND moderation, preventing bursts due to too big ACKs
  * in dubious situations.
  */
static __inline__ void tcp_moderate_cwnd(struct tcp_opt *tp)
{
        u32 t = tcp_packets_in_flight(tp) + tcp_max_burst(tp);
         if (t < tp->snd_cwnd) {
                         tp->snd_cwnd = t;
                         WEB100_VAR_INC(tp, OtherReductions);
          }
         tp->snd_cwnd_stamp = tcp_time_stamp;
}



------------------------------------------------------------------------ 
-------------------
   Brian L. Tierney,   Lawrence Berkeley National Laboratory (LBNL)
   1 Cyclotron Rd.  MS: 50B-2239,  Berkeley, CA  94720
   tel: 510-486-7381    fax: 510-495-2998   efax:  240-332-4065
   bltierney@lbl.gov   http://www-didc.lbl.gov/~tierney
------------------------------------------------------------------------ 
------------------
