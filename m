From: Madanlal Musuvathi <madan@cs.Stanford.EDU>
Subject: clarification regarding tcp_sequence() fn
Date: Wed, 17 Sep 2003 11:29:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16232.43027.255833.806157@chicory.Stanford.EDU>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
 In tcp_input.c the function tcp_sequence is defined as follows

static inline int tcp_sequence(struct tcp_opt *tp, u32 seq, u32 end_seq)
{
	return	!before(end_seq, tp->rcv_wup) &&
		!after(seq, tp->rcv_nxt + tcp_receive_window(tp));
}

I read this as (after inlining tcp_receive_window()): 
  A received tcp packet is in sequence if
     end_seq >= tp->rcv_wup &&
     seq <= tp->rcv_wup + tp->rcv_wnd  

However, this function accepts a packet that is just to the left of the
window (end_seq == tp->rcv_wup). Is this intentional?

If such a packet arrives, RFC requires that a duplicate acknowledgment be
sent.  The linux tcp (atleast 2.4.19 & the latest 2.5 version from
bitkeeper) would not acknowledge such packets in some cases. (Specifically
those cases where the conditions in __tcp_ack_snd_check() fail.)

madan
