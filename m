From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] IPv6: Fix broken anycast usage
Date: Tue, 15 Jul 2003 04:29:44 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307150029.EAA06610@dub.inr.ac.ru>
References: <1057997590.1142.31.camel@hades>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mika.liljeberg@welho.COM (Mika Liljeberg)
In-Reply-To: <1057997590.1142.31.camel@hades> from "Mika Liljeberg" at éÀÌ 12, 2003 12:45:01 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> this doesn't need to be policed. In general, there is no reliable way to
> check if a remote address is anycast, anyway. From RFC2461:
> 
>                  Note that an anycast address is syntactically
>                  indistinguishable from a unicast address.

This is right. (Well, except for the fact that reserved anycasts
are very well syntactically distinguished. :-)) But this does not matter,
the patch is correct, ANYCAST is an additional attribute on unicast
addresses and it should be checked only in contexts where _this_ host
is a member of this anycast.

BTW it is an addendum to my previous mail. You were right complaining
about EINVAL for anycast nexthop. However:

Nexthop address is unique identifier of nexthop router. We do not enforce
this policy (see comments in route.c), hence it is bug to reject such routes
and you are right, but this does not make your example more reasonable.
Any non-unicast non-linklocal address used as nexthop is bad idea,
this policy is not enforced to allow use of global nexthops on BGP routers,
where it is convenient to use global addresses for nexthop resolution and
where it is legal because they are not expected to receive redirects
This is legal in your case of PtP link too, however, this is still nasty.

Alexey
