From: =?gb2312?B?1cXKpL7Z?= <zhangshengju@cmss.chinamobile.com>
Subject: RE: [iproute2] iplink: add support for IFLA_CARRIER attribute
Date: Thu, 27 Apr 2017 14:35:01 +0800
Message-ID: <002301d2bf20$6647b5c0$32d72140$@cmss.chinamobile.com>
References: <1493190519-5518-1-git-send-email-zhangshengju@cmss.chinamobile.com> <20170426080732.51f56b8c@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="gb2312"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "'Stephen Hemminger'" <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:50425 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162110AbdD0GfE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 02:35:04 -0400
In-Reply-To: <20170426080732.51f56b8c@xeon-e3>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Wednesday, April 26, 2017 11:08 PM
> To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> Cc: netdev@vger.kernel.org
> Subject: Re: [iproute2] iplink: add support for IFLA_CARRIER attribute
> 
> On Wed, 26 Apr 2017 15:08:39 +0800
> Zhang Shengju <zhangshengju@cmss.chinamobile.com> wrote:
> 
> > Add support to set IFLA_CARRIER attribute.
> >
> > Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> > ---
> >  ip/iplink.c | 12 ++++++++++++
> >  1 file changed, 12 insertions(+)
> >
> > diff --git a/ip/iplink.c b/ip/iplink.c index 866ad72..263bfdd 100644
> > --- a/ip/iplink.c
> > +++ b/ip/iplink.c
> > @@ -72,6 +72,7 @@ void iplink_usage(void)
> >  		"	                  [ allmulticast { on | off } ]\n"
> >  		"	                  [ promisc { on | off } ]\n"
> >  		"	                  [ trailers { on | off } ]\n"
> > +		"	                  [ carrier { on | off } ]\n"
> >  		"	                  [ txqueuelen PACKETS ]\n"
> >  		"	                  [ name NEWNAME ]\n"
> >  		"	                  [ address LLADDR ]\n"
> > @@ -673,6 +674,17 @@ int iplink_parse(int argc, char **argv, struct
> iplink_req *req,
> >  				req->i.ifi_flags |= IFF_NOARP;
> >  			else
> >  				return on_off("arp", *argv);
> > +		} else if (strcmp(*argv, "carrier") == 0) {
> > +			int carrier;
> > +			NEXT_ARG();
> > +			if (strcmp(*argv, "on") == 0)
> > +				carrier = 1;
> > +			else if (strcmp(*argv, "off") == 0)
> > +				carrier = 0;
> > +			else
> > +				return on_off("carrier", *argv);
> > +
> > +			addattr8(&req->n, sizeof(*req), IFLA_CARRIER,
> carrier);
> >  		} else if (strcmp(*argv, "vf") == 0) {
> >  			struct rtattr *vflist;
> >
> 
> The general policy of ip link command is all options should be invertable.
Yes, so I add 'on' and 'off' subcommand to make sure that it can be
invertable.

> There are some VPN's that use this to save and restore state. So if you
add
> an option to set something there should be similar output under the
detailed
> show command.
Currently, "show command" already can display 'carrier' status. Such as:
 dummy0: <NO-CARRIER...>
