From: Bill Fink <billfink@mindspring.com>
Subject: Re: specifying scopid's for link-local IPv6 addrs
Date: Wed, 25 Jul 2007 02:15:05 -0400
Message-ID: <20070725021505.62a646ea.billfink@mindspring.com>
References: <46A4FAFF.8010809@hp.com>
	<20070724030115.3208229d.billfink@mindspring.com>
	<46A63327.6010705@hp.com>
	<1185298111.17202.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:55164 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752744AbXGYGPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 02:15:12 -0400
In-Reply-To: <1185298111.17202.4.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Jul 2007, Sridhar Samudrala wrote:

> On Tue, 2007-07-24 at 10:13 -0700, Rick Jones wrote:
> > > Rick,
> > > 
> > > I don't see any way around this.  For example, on one of my test
> > > systems, I have the following link local routes:
> > > 
> > > chance% netstat -A inet6 -rn | grep fe80::/64
> > > fe80::/64                                   ::                                      U     256    0        0 eth0
> > > fe80::/64                                   ::                                      U     256    0        0 eth2
> > > fe80::/64                                   ::                                      U     256    0        0 eth3
> > > fe80::/64                                   ::                                      U     256    0        0 eth4
> > > fe80::/64                                   ::                                      U     256    0        0 eth5
> > > fe80::/64                                   ::                                      U     256    0        0 eth6
> > > 
> > > So if I want to run a link local test to fe80::202:b3ff:fed4:cd1,
> > > the system has no way to choose which is the correct interface to
> > > use for the test, and will give an error if the interface isn't
> > > specified. 
> > 
> > Yeah, I was wondering about that.  I'm not sure if the attempts on "those other 
> > OSes" happened to involve multiple interfaces or not.  Even so, it "feels" 
> > unpleasant for an application to deal with and I wonder if there is a way for a 
> > stack to deal with it on the application's behalf.  I guess that might involve 
> > some sort of layer violation between neightbor discovery and routing (typing 
> > while I think about things I know little about...)
> > 
> > Is there RFC chapter and verse I might read about routing with multiple 
> > link-local's on a system?
> > 
> > > You must explicitly specify the desired interface.  For example,
> > > on my test system, the correct interface is eth6 which is interface 8
> > > (lo eth0 eth1 eth2 ... eth5 eth6).  Here is an example nuttcp test
> > > specifying interface 8:
> > > 
> > > chance% nuttcp -P5100 fe80::202:b3ff:fed4:cd1%8
> > >  1178.5809 MB /  10.02 sec =  986.2728 Mbps 12 %TX 15 %RX
> > > 
> > > nuttcp uses getaddrinfo() which parses the "%<ifindex>" field,
> > > and then copies the sin6_scope_id from the res structure to the
> > > server's sockaddr_in6 structure before initiating the connect().
> > 
> > OK, I'll give that a quick try with netperf:
> > 
> > [root@hpcpc106 ~]# netperf -H 192.168.2.107 -c -C -i 30,3 -- -s 1M -S 1M -m 64K 
> > -H fe80::207:43ff:fe05:9d%2
> 
> We can even specify the interface name instead of the interface index
>    <link-local>%ethX
> 
> getaddrinfo() uses if_nametoindex() internally to get the index.
> 
> Thanks
> Sridhar

Cool!  That's much easier and works great.  :-)

chance% nuttcp -P5100 fe80::202:b3ff:fed4:cd1%eth6
 1178.5468 MB /  10.02 sec =  986.3239 Mbps 13 %TX 15 %RX

Still learn something new every day.  Now if I just could remember
it all when I needed it later.  :-)

						-Thanks

						-Bill
