From: Scott Mcdermott <smcdermott@questra.com>
Subject: Re: [IPSEC] Too many SADs!
Date: Tue, 22 Mar 2005 14:48:21 -0800
Message-ID: <20050322224819.GB4924@questra.com>
References: <200503220052.52756.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <200503220052.52756.wolfgang.walter@studentenwerk.mhn.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Wolfgang Walter on Tue 22/03 00:52 +0100:
> We had the same problem. Seems to be a limitation of the
> pfkey-implementation of linux.
> 
> racoon and setkey both use the pfkey-interface.
> 
> We switched to iproute2 and openswan which both use the
> netfilter-interface.  Therefor they can handle thousands
> of SAD and SPD rules.

What, openswan uses PF_KEY last I checked on kernel 2.6.  I
guess you can use KLIPS, but why would you? What's this
"netfilter-interface" to ipsec code?

I had the exact same problem the original poster had with
Racoon.  SPDs would multiply without bounds, seemingly
geometrically.

I switched to strongswan and the problems immediately
vanished.  There is some bug in racoon where it doesn't
replace SPDs.  I used the latest ipsec-utils and kernel and
this problem did not go away until I switched instead to
strongswan (still using PF_KEY) (it also worked with
openswan).
