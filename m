From: Steve Modica <modica@sgi.com>
Subject: High interrupt rate on tg3 driver
Date: Wed, 05 Nov 2003 14:41:46 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FA9608A.1020706@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi All,

It turns out that there's a hardware bug that can cause a missed interrupt with 
the 570X chipset.  So the tg3 driver will poke the card every 10msec to make 
sure we don't miss one.  Each of these pokes generates an interrupt.

However this still doesn't explain the high interrupt rate I'm seeing. I'm 
seeing about 22k/sec when moving 500kBytes/sec of data.

I've got 5 cards ports on the system, so I can account for 500/sec, and I could 
even see each NAPI interrupt/poll cycle generating a few hundred a sec, but 
22000 seems like way too many.

Can anyone think of a real good way to capture this?  Profiling just shows me 
spending a lot of time in tg3_poll, do_csum and memcpy.

Steve


-- 
Steve Modica
work: 651-683-3224
MTS-Technical Lead
"Give a man a fish, and he will eat for a day, hit him with a fish and
he leaves you alone" - me
