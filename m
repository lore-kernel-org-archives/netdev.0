From: "CIT/Paul" <xerox@foonet.net>
Subject: RE: Route cache performance under stress
Date: Tue, 10 Jun 2003 17:36:14 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <012301c32f98$52043dd0$4a00000a@badass>
References: <20030610.115759.26513736.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <ralph+d@istop.com>, <ralph@istop.com>, <hadi@shell.cyberus.ca>,
   <sim@netnation.com>, <fw@deneb.enyo.de>, <netdev@oss.sgi.com>,
   <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'David S. Miller'" <davem@redhat.com>, <Robert.Olsson@data.slu.se>
In-Reply-To: <20030610.115759.26513736.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Why do you need source validation if we are going to use it for a core
router :)
Is there anything else in there that may or may not be necessary
depending on the circumstances that we are using the router for?


Paul xerox@foonet.net http://www.httpd.net


-----Original Message-----
From: David S. Miller [mailto:davem@redhat.com] 
Sent: Tuesday, June 10, 2003 2:58 PM
To: Robert.Olsson@data.slu.se
Cc: ralph+d@istop.com; ralph@istop.com; hadi@shell.cyberus.ca;
xerox@foonet.net; sim@netnation.com; fw@deneb.enyo.de;
netdev@oss.sgi.com; linux-net@vger.kernel.org
Subject: Re: Route cache performance under stress


   From: Robert Olsson <Robert.Olsson@data.slu.se>
   Date: Tue, 10 Jun 2003 20:34:50 +0200
   
   I ripped out the route hash just to test the slow path. Seems like
your 
   patch was very good as we see the same performance w/o dst hash ~114
kpps.

How did you "rip it out"?  Just never look into the routing cache hash
and never add entries there?  If so, then yes it is excellent simulation
for pure slow path.

This is not purely an algorithmic problem.  The highest cost thing we do
in the slow path of input route processing is source validation. This
requires real brains to eliminate.

Actually, that's a good idea, if someone if brave just rip out
fib_validate_source (just don't call it, should work for valid
traffic) and see what happens :)
