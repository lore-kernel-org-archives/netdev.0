From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Re: [IPSEC] Too many SADs!
Date: Wed, 23 Mar 2005 13:22:07 +0100
Message-ID: <200503231322.07455.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> What, openswan uses PF_KEY last I checked on kernel 2.6.  I
> guess you can use KLIPS, but why would you? What's this
> "netfilter-interface" to ipsec code?
> 

Sorry, meant netlink-interface.

> I had the exact same problem the original poster had with
> Racoon.  SPDs would multiply without bounds, seemingly
> geometrically.

> I switched to strongswan and the problems immediately
> vanished.  There is some bug in racoon where it doesn't
> replace SPDs.  I used the latest ipsec-utils and kernel and
> this problem did not go away until I switched instead to
> strongswan (still using PF_KEY) (it also worked with
> openswan).

We don't use openswan with KLIPS but with native ipsec.

I'm rather sure that openswan 2.3.0 uses netlink with native ipsec - there is 
no pfkey-socket open when running pluto and pluto opens a netlink-socket.

Does not really matter. The problem of racoon is that it does a spd-dump when 
started. The kernel seems to run out of memory when generating such a huge 
pfkey-message.

The same is true for setkey. You can use it to add thousands of spd-rules but 
you may not dump (and so list) them (you can use iproute2 to check that 
setkey really added those entries).

So we use iproute2 to flush and list our spd and to set up static spd-rules 
(especially those for discard and none policies). We use pluto from openswan 
2.3.0 for IKE.

Greetings,

Wolfgang Walter
