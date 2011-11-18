From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: ipv4 udplite broken in >=linux-3.0 ?
Date: Fri, 18 Nov 2011 13:04:30 +0100
Message-ID: <20111118120430.GG3317@hell>
References: <CABPbr_msepemFt4ezGVRk3QS0MU3F47MKimfV4Y+6jqvUrLFeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gerrit@erg.abdn.ac.uk, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jinxin Zheng <jinxinzheng@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CABPbr_msepemFt4ezGVRk3QS0MU3F47MKimfV4Y+6jqvUrLFeA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Jinxin Zheng | 2011-11-18 12:09:25 [+0800]:

>I don't know how to debug udplite. Can any one of you give me a tip on
>how to get more debug info, then I can do further test and provide
>with it?

net-next works for me:

$ sudo aptitude install netsend
$ sudo tcpdump -n -ttt -vv -i lo > pcap.trace &
$ netsend udplite receive &
$ netsend udplite transmit /etc/fstab 127.0.0.1

$ cat pcap.trace
00:00:00.000000 IP (tos 0x0, ttl 64, id 30602, offset 0, flags [DF], proto unknown (136), length 40) 127.0.0.1 > 127.0.0.1:  udplite 20
00:00:00.000074 IP (tos 0x0, ttl 64, id 30603, offset 0, flags [DF], proto unknown (136), length 1125) 127.0.0.1 > 127.0.0.1:  udplite 1105


Kernel version? What is the output of strace?
