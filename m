From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 18:01:20 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610.180120.71112140.davem@redhat.com>
References: <20030610.152020.59678979.davem@redhat.com>
	<Pine.LNX.4.51.0306101956520.7801@ns.istop.com>
	<3EE67D2D.80608@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralph+d@istop.com, Robert.Olsson@data.slu.se, hadi@shell.cyberus.ca,
   xerox@foonet.net, sim@netnation.com, fw@deneb.enyo.de, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com
In-Reply-To: <3EE67D2D.80608@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ben Greear <greearb@candelatech.com>
   Date: Tue, 10 Jun 2003 17:51:57 -0700
   
   Maybe as a configurable option, since it would make tcpdump less useful.
   Seems like we could kludge it up so that we used the TSC (or whatever that
   really fast hardware clock is) to provide some relative stamp that could be
   converted to a time_val later?

I have a strange feeling that Ralph's system isn't using
TSC and that's why it shows up so high on the profiles :-)
TSC do_gettimeofday() is REALLY cheap (TSC read plus a multiply which
x86 does in like 5 cycles).

Yes, this idea has been tossed around before.  But what's funny
is that on the bigger boxes, you don't use TSC because amongst
the different nodes of the machine they are skewed, so you have
to use the ACPI timer or something like that for timestamping.
   
   It does seem a bit wasteful to do the gettimeofday when most of the time
   the result is ignored.
   
   (Or, are there things other than tcpdump that need the gettimeofday stamp?)

SO_RECVSTAMP, any socket on the machine can ask for this.
