From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH][IPV6] fixed authentication error with TCP
Date: Mon, 18 Aug 2003 03:29:50 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308172329.DAA14889@dub.inr.ac.ru>
References: <20030807220539.4555db2d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kazunori@miyazawa.org, netdev@oss.sgi.com, usagi@linux-ipv6.org,
   latten@austin.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20030807220539.4555db2d.davem@redhat.com> from "David S. Miller" at Aug 07, 2003 10:05:39 PM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> But I see a small area for improvement.  Look at the place inside
> of ip6_dst_lookup() where we do source address selection.  If this
> fails, we mark error to dst->error.
.....
> It seems to me that it is only OK for dst->error to be set on routes
> that may not be used validly for anything.
> 
> Alexey, do I understand this stuff correctly?

I think you do. And this is rather severe bug than area for improvement.
It definitely corrupts routing table.

Well, I think switching from function returning error code to a function
returning dst is not a very good idea. This never was convenient.
In the case of error, IPv6 used to return to caller a dummy reject route,
which is always -ENETRUNREACH. So, to do this we have to hold a route
for each errno. Returning int was just better.

Alexey
