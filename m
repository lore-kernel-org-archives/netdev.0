From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: sctp snmp mib stats in /proc/net/snmp
Date: Tue, 05 Nov 2002 14:33:43 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DC84747.67C80B24@us.ibm.com>
References: <Pine.LNX.4.44.0210290912580.3213-100000@w-nivedita.beaverton.ibm.com> <20021029.091823.121274899.davem@redhat.com> <3DBEC628.75396DA@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org,
   lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nivedita Singhvi wrote:
> 
> "David S. Miller" wrote:

> > Where will sctp_statistics be defined?  If it will be in net/sctp/*.c,
> > then you will need to ifdef this ipv4 procfs code on CONFIG_IP_SCTP
> 
> Rats, yes, it is in net/sctp/protocol.c. I'll move it under the ifdef
> and make up a complete patch with the dependent code for review
> purposes and repost. Thanks for the catch!

My apologies for the latency in getting back on this (critical 
interrupts from other directions)..

We're considering a modification to the original proposal, which 
was to display SCTP SNMP stats in /proc/net/snmp along with the
other AF_INET protocols currently being displayed. 

We're now considering simply displaying the sctp stats structures
(snmp and other extended) under the /proc/net/sctp/ subdirectory.

This is due to several reasons - one is that the CONFIG_IP_SCTP
def isnt enough. SCTP can also be compiled as a module, and may
or may not be loaded. We cant make assumptions in net/ipv4/proc.c
about whether the sctp_statistics structure is available or not..
Note #if defined (CONFIG_IP_SCTP) || defined (CONFIG_IP_SCTP_MODULE)
isnt enough. A clean way to do this would be to have an af_inet
top level registration process and have the sctp module register
when loaded, as is typical elsewhere. We really dont want to do
this at this point, and introduce too many dependencies on directories
outside of net/sctp at this time.

Secondly, the SCTP MIB is still being formed, and we're probably 
going to need additions/changes to the spec. In the interim, (or
possibly, permanently) we're going to need extended sctp stats which
arent in the spec, much like the current linux mib struct which 
defines a set of extended TCP counters. 

It would be easier to manage this under the sctp subdirectory
altogether. i.e. We diplay the SCTP SNMP and other extended stats
as /proc/net/sctp/snmp and /proc/net/sctp/sctp_mib or some such
name (which would be somewhat dynamic short term). This would also
solve unnecessary duplication for AF_INET6 for us.

Any issues, thoughts, suggestions? 

thanks,
Nivedita
