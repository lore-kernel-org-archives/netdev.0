From: Jason Lunz <lunz@falooley.org>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Wed, 9 Mar 2005 16:46:02 +0000 (UTC)
Message-ID: <d0n98a$icn$1@sea.gmane.org>
References: <Pine.LNX.4.61.0503090009120.6780@filer.marasystems.com> <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net> <20050306173145.GQ31837@postel.suug.ch> <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net> <m1y8d0mss2.fsf@muc.de> <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net> <422C0B50.20500@mrv.com> <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net> <1110288879.1050.167.camel@jzny.localdomain> <20050308135134.GA20607@atrey.karlin.mff.cuni.cz> <1110290300.1050.190.camel@jzny.localdomain> <20050308140301.GC20607@atrey.karlin.mff.cuni.cz> <1110291470.1043.211.camel@jzny.localdomain> <Pine.LNX.4.61.0503081937020.5332@filer.marasystems.com> <1110316631.1084.57.camel@jzny.localdomain> <Pine.LNX.4.61.0503090009120.6780@filer.marasystems.com> <E1D91Rz-0004wp-00@smtp01.mrf.mail.rcn.net> <1110377889.1090.124.camel@jzny.localdomain>
Cc: linux-net@vger.kernel.org
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hadi@cyberus.ca said:
> Are we still talking about the same problem? The linecards addresses
> and interconnect interfaces are "internal". They are never
> advertised/seen outside of the chasis. So if you choose 18.7.22.69/32
> to use internally you make sure it is never advertised to the outside
> world as belonging to you. If you have to advertise it or actually
> know it is used, then you must deal with the conflict.

I think you're both in agreement, however violently you try not to be.
The question, though, is: *How* do you configure the nodes within the
chassis such that the internal IPs (whatever they are) _stay_ internal,
and any non-127/8 addressing can be used for the external interfaces?

I've done something similar, for example, using policy routing and the
arp sysctls. Suppose you have a machine with 2 interfaces, and you want
IP routing to happen on each of the two interfaces as independently as
possible. My solution involves using the "iif" modifier in your routing
rules ("ip rule" rules) to send packets to two completely different
routing tables, and making sure arp doesn't bleed across the two
interfaces. I don't know whether policy routing gives enough control to
do this in a general fashion; i did it only for very specific types of
traffic. But I suspect you could come up with something workable.

Jason
