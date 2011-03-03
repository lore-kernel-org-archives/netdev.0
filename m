From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Subject: Re: Bad performance when CUBIC HyStart enabled
Date: Thu, 3 Mar 2011 18:37:33 +0100
Message-ID: <20110303173733.GB8028@xanadu.blop.info>
References: <20110303142229.GA9262@xanadu.blop.info>
 <1299164580.2983.99.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="W/nzBZO5zC0uMSeA"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Sangtae Ha <sha2@ncsu.edu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([178.79.145.134]:57108 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758221Ab1CCRh3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 12:37:29 -0500
Content-Disposition: inline
In-Reply-To: <1299164580.2983.99.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On 03/03/11 at 16:03 +0100, Eric Dumazet wrote:
> Le jeudi 03 mars 2011 à 15:22 +0100, Lucas Nussbaum a écrit :
> > Hi,
> > 
> > I'm experiencing bad performance transferring data over a large BDP
> > network with CUBIC when HyStart is enabled. Disabling HyStart fixes the
> > problem.
> > 
> > Test setup:
> > I'm transfering a 2-GB file between two machines using netcat. On both
> > machines, /dev/shm is used to store the data.
> > On the sending side, I use:
> > /dev/shm# while true; do dd if=foo bs=10M | nc -l -p 2222 -q 0; done
> > On the receiving side, I use:
> > /dev/shm# /usr/bin/time nc 131.254.203.6 2222 > foo
> > Both machines are on Gigabit ethernet networks, and the RTT between them
> > is 11.3ms.
> > The default sysctl values are used.
> > I use nload -i 1000000 -o 1000000 -u m eth0 to visualize the transfer
> > rate.
> > 
> > With a 2.6.26 kernel, everything is fine. The bandwidth quickly gets to
> > ~940 Mbps, and I get the following in nload:
> >       ..................................
> >      .##################################
> >      ###################################
> >      ###################################
> >      ###################################
> >      ####################################
> >      ####################################
> >      ####################################
> >      ####################################
> >      ####################################
> >      ####################################
> >      ####################################
> >      ####################################
> >      ####################################
> > The transfer time is 18.2s, which is reasonable for a 2-GB file.
> > 
> > With a 2.6.32 kernel (Debian's) or with a 2.6.37 kernel (on the sending
> > side only), with the default HyStart parameters, I get the following:
> >                            ..........................
> >                           |##########################.
> >                          |############################
> >                         |#############################
> >                        |##############################
> >                       |###############################
> >                     .#################################
> >                    |##################################| 
> >                  |##################################### 
> >             ..||####################################### 
> >     ....|############################################## 
> >  .##################################################### 
> > The transfer time is 26.8s. (There's one character every 0.5s on the
> > graph above)
> > 
> > Disabling hystart on the sending machine with:
> > echo 0 > /sys/module/tcp_cubic/parameters/hystart
> > Fixes the problem.
> > 
> > It seems that waiting for some time (or rebooting) fixes the problem for
> > some time, so I'm suspecting that the problem is caused by a cache of
> > some sort. However, doing:
> > echo 1 > /proc/sys/net/ipv4/route/flush
> > doesn't fix the problem.
> > 
> > Ideas? I could arrange to give access to the testbed if needed.
> > (https://www.grid5000.fr/)
> 
> eventually, after fresh boot of both sender/receiver, it would be nice
> to have "netstat -s" results after one transfert with said problems.

Hi,

Attached.

I had 6 successful transfers. There's the netstat -s output after the 5
first successful transfers. Then the 7th transfer showed the problem,
as well as the 8th and the 9th. There's the netstat -s output after each
of them.
-- 
| Lucas Nussbaum             MCF Université Nancy 2 |
| lucas.nussbaum@loria.fr         LORIA / AlGorille |
| http://www.loria.fr/~lnussbau/  +33 3 54 95 86 19 |

--W/nzBZO5zC0uMSeA
Content-Type: application/x-gtar
Content-Disposition: attachment; filename="netstat-s.tgz"
Content-Transfer-Encoding: base64

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
4r4lAKAAAA==

--W/nzBZO5zC0uMSeA--
