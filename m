From: Pekka Savola <pekkas@netcore.fi>
Subject: Disabling IPv6 accept_ra on just some interface
Date: Thu, 23 Oct 2003 15:22:47 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310231457110.3347-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I've been struggling to be able to disable IPV6 autoconfiguration on just
one interface, but retain it on others.

This appears to be a bit problematic because there exists an obvious race 
condition here: when the autoconf was enabled by default on every 
interface, disabling it afterwards on one particular interface will retain 
the addresses and routes on that interface until their expire.

AFAICS, you should first (before any interface is brought up) disable 
accept_ra for every interface, plus default and all values.

Then, for every interface, after you've loaded the driver (that is, a 
sysctl toggle exists for the device), you either enable the autoconf or 
not.

This is a bit complex, but maybe doable.

Any other ways around this?

The implication is that the kernel will ignore route advertisements, and
does not send the route solicitation itself.  However, the consequence of 
this is that when you enable an interface like this, you'll have to wait 
for the next unsolicited advertisement -- which could take a long while.

So, my thought (comments welcome) is:

 1) when accept_ra changes from 0 -> 1, initiate the route 
    solicitation process, likewise as one would when the interface is 
    brought up.

    Makes sense?

 2) (probably not a good idea, but some food for thought..) when accept_ra 
    changes from 1 -> 0, delete any autoconfigured routes or
    prefixes.  (could be ugly / dangerous..)

(similar toggle could be in place for "autoconf" which could be used to 
generate the link-local addresses or maybe even kill them if you didn't 
want them for the general case.)

Thoughts?

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
