From: Jaume Catarineu <jaume.catarineu@upf.edu>
Subject: Re: Kernel BUG: Qos seg. fault
Date: Tue, 25 May 2004 02:06:25 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40B2AA21.7080700@upf.edu>
References: <20040524215346.73109.qmail@web80501.mail.yahoo.com> <1085436571.1041.69.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Dmitry Torokhov <dtor_core@ameritech.net>
In-Reply-To: <1085436571.1041.69.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,

After reading all your messages I share the Dmitry's point of view. It 
seems quite clear that implementing filters for TBF does not make sense. 
  However, if it is the case, it could be nice a warning message that 
informs the user about the weird command introduced.

Another option (a little more complicated) would be to "decay" 
automatically the filter to the TBF's child qdisc. That ougth to be 
announced to the user also and maybe it won't be allways possible (with 
the default noop_qdisc is useless, isn't it?).

I will take a tour into the source code :)

Actually, the original sequence must be rewrited to:
  tc qdisc add dev lo root handle 1: tbf rate 250kbit burst 5k limit 5k
  tc qdisc add dev lo parent 1: handle 20:  prio
  tc qdisc add dev lo parent 20:1 handle 210: sfq perturb 10
  tc qdisc add dev lo parent 20:2 handle 220: tbf rate 250kbit limit 5k 

  tc qdisc add dev lo parent 20:3 handle 230: sfq perturb 10

  tc filter add dev lo protocol ip parent 20: prio 1 handle 2 \
                                              fw flowid 20:3

The key is the "parent 20:" (not the original "parent 1:") in the filter 
line.

I must say that I got astonished viewing how quick you solved the quiz. 
Now I don't simply believe in free software, now I really TRUST in it.

Jaume,
