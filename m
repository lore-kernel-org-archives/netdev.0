From: Ralph Doncaster <ralph@istop.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 20:41:13 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.51.0306102030530.12166@ns.istop.com>
References: <Pine.LNX.4.51.0306101725020.17226@ns.istop.com>
 <20030610.152020.59678979.davem@redhat.com> <Pine.LNX.4.51.0306101956520.7801@ns.istop.com>
 <20030610.165759.78731321.davem@redhat.com>
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
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030610.165759.78731321.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Tue, 10 Jun 2003, David S. Miller wrote:

>    From: Ralph Doncaster <ralph@istop.com>
>    Date: Tue, 10 Jun 2003 19:58:47 -0400 (EDT)
>
>    On Tue, 10 Jun 2003, David S. Miller wrote:
>
>    > Every packet records a timestamp.
>
>    I'm not aware of anything in IP routing that requires a timestamp for
>    every packet.  To me it sounds like we could rip that out too.
>
> Guess you never run tcpdump nor use packet schedulers.

So because some (in the case of a core router almost none) of the packets
will need a timestamp, you do it for every single one of them?

This sounded so unbelievable to me that I took a quick look at the code to
see what I'd have to do to get rid of it.  It appears that gettimeofday is
not called for every packet; just for ICMP timestamp requests and for IP
options (ip_options_build and ip_options_compile).

-Ralph
