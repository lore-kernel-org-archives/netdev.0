From: jamal <hadi@cyberus.ca>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: 11 Sep 2003 23:05:54 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063335511.1031.38.camel@jzny.localdomain>
References: <OFF6DA8E51.7C3572D3-ON85256D9F.000B88F1-86256D9F.000CB34F@us.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, jgarzik@pobox.com, scott.feldman@intel.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ricardo C Gonzalez <ricardoz@us.ibm.com>
In-Reply-To: <OFF6DA8E51.7C3572D3-ON85256D9F.000B88F1-86256D9F.000CB34F@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-09-11 at 22:20, Ricardo C Gonzalez wrote:
> Jamal wrote:

>       We should care about counting the packets being dropped on the
> transmit side. Would it be the responsability of the driver to account for
> this drops? Because each driver has a dedicated software queue and in my
> opinion, the driver should account for this packets.

This is really the schedulers responsibility. Its hard for the driver to
keep track of why a packet was dropped. Example, could be dropped to
make room for a higher priority packet thats being anticipated to show
up soon.

The simple default 3-band scheduler unfortunately doesnt quiet show its
stats ...so simple way to see drops is:

- install the prio qdisc 
------
[root@jzny root]# tc qdisc add dev eth0 root prio
[root@jzny root]# tc -s qdisc
qdisc prio 8001: dev eth0 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1
1
 Sent 42 bytes 1 pkts (dropped 0, overlimits 0) 
-----

or you may wanna install a single pfifo queue with size of 1000 each
(although this is a little too mediavial)

example:
#tc qdisc add dev eth0 root pfifo limit 1000
#tc -s qdisc
qdisc pfifo 8002: dev eth0 limit 1000p
 Sent 0 bytes 0 pkts (dropped 0, overlimits 0) 

etc

cheers,
jamal
