From: Ralph Doncaster <ralph@istop.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 17:39:44 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.51.0306101725020.17226@ns.istop.com>
References: <Pine.LNX.4.51.0306101332300.8755@ns.istop.com>
 <20030610.103234.116374169.davem@redhat.com> <16102.9418.43884.336925@robur.slu.se>
 <20030610.115759.26513736.davem@redhat.com>
Reply-To: ralph+d@istop.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Robert.Olsson@data.slu.se" <Robert.Olsson@data.slu.se>,
   "hadi@shell.cyberus.ca" <hadi@shell.cyberus.ca>,
   "xerox@foonet.net" <xerox@foonet.net>,
   "sim@netnation.com" <sim@netnation.com>,
   "fw@deneb.enyo.de" <fw@deneb.enyo.de>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
   "linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030610.115759.26513736.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 10 Jun 2003, David S. Miller wrote:

> Actually, that's a good idea, if someone if brave just rip out
> fib_validate_source (just don't call it, should work for valid
> traffic) and see what happens :)

Looking at Simon's profile numbers, these seem to contribute a lot more
than fib_validate_source:
  1237 ipt_route_hook                            19.3281
  3120 do_gettimeofday                           21.6667
  8299 ip_packet_match                           24.6994
  8031 fib_lookup                                25.0969
  1877 fib_rule_put                              29.3281

What's the do_gettimeofday for?  Is that just a bogus one that shows up
for kernel profiling (I can recall using the profiling tool quantify had a
similar problem of showing gettimeofday calls that it was doing on its
own).

I traced back the fib_lookup to ip_forward_finish, which seems to only
call ip_forward_options when there's IP options (go figure!), which would
make sense for a SYN packet (juno).  What I can't think of is why we'd
want to have special routing considerations for TCP SYN packets (and other
IP packets with options set).

-Ralph
