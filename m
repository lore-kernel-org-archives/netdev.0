From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: Multicast on b44
Date: Sun, 16 Jan 2005 01:38:36 +0200
Message-ID: <20050115233836.GA5334@ee.oulu.fi>
References: <f3ddc6d305011320416635914@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Hubbard <jameshubbard@gmail.com>
Content-Disposition: inline
In-Reply-To: <f3ddc6d305011320416635914@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 13, 2005 at 11:41:12PM -0500, James Hubbard wrote:
> I spoke to one of the developers of the communication software.  He
> checked things in a limited way.  This was his take on things.
> 
> "Okay, so I went and looked at the source to the b44 driver that comes
> with Fedora 1, and downloaded the 7.3.5 and 3.0.8 versions of the
> drivers from the broadcom web site."
> 
> "I'm not sure which chip you've got or which driver you're running, but
> the b44 driver looks like it's completely broken as soon as you go over
> about 30 multicast groups.  It just sort of randomly stops accepting new
> joins and so forth.  The ones from broadcom seem a little bit better,
> but are still a little bogus looking."
> 
> Do you have any suggestions that might help us to fix the problem?
Hiya

It looks like the b44 driver is limited to 32 entries (B44_MCAST_TABLE_SIZE)
whereas bcm4400 goes up to 63. It's just a #define so you should be able to
up it to that and be safe, might be worth upping it to that in b44 by
default. 

If you need more than that you're stuck with allmulti, which if I remember
correctly didn't work. Yup, from a previous mail of mine I did test it at
one point:

"Ok, after some digging around ALLMULTI breaking is not a bug, the
vendor-provided driver seems to break in similar ways, at least on 2.6,
so that's a feature unless they fix it in theirs so I can copy the fix :-)"

(well, it receive all multicasts after that, just not any unicasts :-) ).
Might be worth checking if the latest one of theirs still does that.
Wouldn't be surprised if it was a hardware bug...

Another option is promiscuous, which definately does work since I've used
tcpdump quite a bit :-). If it's a hardware bug with allmulti I suppose
just making allmulti == promiscuous.

Debugging this kind of things is very difficult though, since the only
source of documentation I have is the bcm4400 driver. And now that I
upgraded my system to a nice Athlon 64 with dual GigE I don't have the
hardware to test with either, so there's not much I can do to the driver
anyway other than point people to stuff, make "it compiles" patches and hope
someone tests and fixes them :-/
