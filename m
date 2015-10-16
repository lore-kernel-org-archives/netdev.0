From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] ip route get: change exit to return to support
 batch commands
Date: Fri, 16 Oct 2015 09:08:34 +0300
Message-ID: <20151016060834.GA13468@angus-think.lan>
References: <1444947830-19858-1-git-send-email-roopa@cumulusnetworks.com>
 <56206314.6020601@cumulusnetworks.com>
 <56206B53.1080709@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsa@cumulusnetworks.com>, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:34388 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183AbbJPGMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 02:12:22 -0400
Received: by lbbwb3 with SMTP id wb3so29557033lbb.1
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 23:12:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <56206B53.1080709@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 15, 2015 at 08:13:23PM -0700, roopa wrote:
> On 10/15/15, 7:38 PM, David Ahern wrote:
> > Hi Roopa:
> >
> > On 10/15/15 4:23 PM, Roopa Prabhu wrote:
> >> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> >>
> >> replace exit with return -2 on rtnl_talk failure
> >>
> >> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> >> ---
> >>   ip/iproute.c | 2 +-
> >>   1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/ip/iproute.c b/ip/iproute.c
> >> index da25548..b137f55 100644
> >> --- a/ip/iproute.c
> >> +++ b/ip/iproute.c
> >> @@ -1643,7 +1643,7 @@ static int iproute_get(int argc, char **argv)
> >>           req.r.rtm_family = AF_INET;
> >>
> >>       if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0)
> >> -        exit(2);
> >> +        return -2;
> >>
> >>       if (connected && !from_ok) {
> >>           struct rtmsg *r = NLMSG_DATA(&req.n);
> >>
> >
> > Why return -2 vs exit(2)? What does the change mean to a user or the functionality of ip?
> Stephen has documented this someplace. I have seen it before. I now forget where. Right now i am just following
> the rest of the code.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hi,

IMHO I think it would be good to have #define's for these return values.
