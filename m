From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 15:20:20 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030610.152020.59678979.davem@redhat.com>
References: <16102.9418.43884.336925@robur.slu.se>
	<20030610.115759.26513736.davem@redhat.com>
	<Pine.LNX.4.51.0306101725020.17226@ns.istop.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, hadi@shell.cyberus.ca, xerox@foonet.net,
	sim@netnation.com, fw@deneb.enyo.de, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: ralph+d@istop.com, ralph@istop.com
In-Reply-To: <Pine.LNX.4.51.0306101725020.17226@ns.istop.com>
List-Id: netdev.vger.kernel.org

   From: Ralph Doncaster <ralph@istop.com>
   Date: Tue, 10 Jun 2003 17:39:44 -0400 (EDT)
   
   Looking at Simon's profile numbers, these seem to contribute a lot more
   than fib_validate_source:

Ignore all the fib_rule*() and associated overhead, Simon
is going to turn of policy routing support so that stuff
drops out of the profiles.

The fib_lookup() will decrease significantly from the profiles
if fib_validate_source() is deleted, and this is what I want
confirmed from such an experiment.

     1237 ipt_route_hook                            19.3281
     3120 do_gettimeofday                           21.6667
     8299 ip_packet_match                           24.6994
     8031 fib_lookup                                25.0969
     1877 fib_rule_put                              29.3281
   
   What's the do_gettimeofday for?

Every packet records a timestamp.

   I traced back the fib_lookup to ip_forward_finish, which seems to only
   call ip_forward_options when there's IP options (go figure!), which would
   make sense for a SYN packet (juno).

You're thinking TCP options, not IP options.

   What I can't think of is why we'd want to have special routing
   considerations for TCP SYN packets (and other IP packets with
   options set).

ip_forward_options() has to update things like record-route
IP options, which record hop-by-hop information for diagnostic
tools like traceroute.

