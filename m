From: Werner Almesberger <wa@almesberger.net>
Subject: Re: snd_cwnd drawn and quartered
Date: Wed, 15 Jan 2003 15:25:04 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030115152504.B1521@almesberger.net>
References: <20030114033651.S1516@almesberger.net> <200301151750.UAA15907@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, chengjin@cs.caltech.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200301151750.UAA15907@sex.inr.ac.ru>; from kuznet@ms2.inr.ac.ru on Wed, Jan 15, 2003 at 08:50:50PM +0300
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:
>> This is precisely what NewReno does. If you lose anything within
>> that cwnd, recovery is extended.
> 
> Werner, where did you get this information? In that case recovery
> will not finish. :-)

Maybe I used the wrong word. The sequence number we're waiting
for (high_seq) doesn't change, of course. But the recovery
takes longer than just one RTT, because it takes longer for
snd_una to reach high_seq - due to the second loss.

And because recovery takes longer than one RTT, we decrement
cwnd too much.

>> 100:  we've recovered our initial loss, but snd_una is still
>>       below high_seq, because of all the other losses in that
>>       cwnd
> 
> This must not happen. I did not mean this in code and cannot see
> how it can happen. high_seq is set once while single recovery cycle.
> Something is buggy.

Yes, high_seq is set only once. That's okay. It's snd_una that
(correctly) takes more than one RTT to reach high_seq.

1) tcp_enter_loss sets high_seq = snd_nxt. At that time (t = 0),
   snd_una is 0, snd_nxt is 100.
2) tcp_fastretrans_alert tries to exit recovery only if snd_una
   reaches high_seq

Am I reading this right ?

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
