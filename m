From: zrzeng@linuxforum.net
Subject: TCP:Is it possible for both sk->dead==1 and sk->lock.users==1 to be true?
Date: Tue, 7 Oct 2003 12:16:48 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310071209.h97C9F25011515@oss.sgi.com>
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Date: Tue Oct  7 11:52:44 2003 +0000
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, gurus,

In tcp_input.c, function tcp_rcv_state_process(), 
when doing ack processing of state TCP_FIN_WAIT1, 
there are statements (kernel 2.4.21):

    if (!sk->dead)
        ......
    else {
        ......
        if (tmo > TCP_TIMEWAIT_LEN) {
                ......
--->>   } else if (th->fin || sk->lock.users) {
                /* Bad case. We could lose such FIN otherwise.
                 * It is not a big problem, but it looks confusing
                 * and not so rare event. We still can lose it now,
                 * if it spins in bh_lock_sock(), but it is really
                 * marginal case.
                 */
                tcp_reset_keepalive_timer(sk, tmo);
        } else {
                ......
        }

but as far as I understand, 
1)if sk is dead, there would be no process context reference to it.
2)if sk->lock.users==1, it means that some process context is
  referencing it, and most likely it is in backlog processing when 
  doing release_sock().

1) and 2) seems to be a bit conflict to me, 

Am I missing any important points? 

Thank you for your kind help in advance.
