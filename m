From: anand@eis.iisc.ernet.in (SVR Anand)
Subject: netfilter hook in packet capture
Date: Thu, 1 Jan 2004 15:05:47 +0530 (GMT+05:30)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401010935.PAA19361@eis.iisc.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I am hoping that this mail will be relevant to those who have an user level
application that does firewalling by promiscuously capturing packets, apply
extensive decision making rules. I have written one such application and found 
what I am going to say below has helped me a lot.

In the above mentioned scenario, there are many instances I preferred to do
the following in the kernel itself as much as possible before further
processing done in the user firewall code. What I wanted was
i) selective packet capture ii) DoS protection iii) Externally controlling
the kernel level filter rules without disrupting the firewall application 
iv) Ease of filter management  vi) Logging v) Performance ...

I found that iptables/netfilter satisfies all my requirements as compared to
the existing bpf filter. Hence all I had to do was include NF_HOOK at couple
of places in af_packet.c and I have the netfilter features accessible to me.
With the above trivial inclusion I am currently running my application with 
all the initial work done by netfilter. Thanks netfilter group!

While the sanctity or appropriateness or compliance of the above patch within
packet capture scheme of things can be frowned upon, since its utility has 
been beneficial to me, I thought I would share it with you. If you find it
useful I can send you rather simple patch which perhaps you could have easily
guessed it!

Anand
