From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] lib: Replace 16384 netlink buf by macro
Date: Wed, 25 Feb 2015 21:42:34 +0200
Message-ID: <20150225194234.GA3021@angus-think.lan>
References: <1424880257-20657-1-git-send-email-vadim4j@gmail.com>
 <20150225164655.GL2039@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:45194 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644AbbBYTx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 14:53:56 -0500
Received: by labge10 with SMTP id ge10so6285178lab.12
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 11:53:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150225164655.GL2039@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 25, 2015 at 05:46:55PM +0100, Jiri Pirko wrote:
> Wed, Feb 25, 2015 at 05:04:17PM CET, vadim4j@gmail.com wrote:
> >From: Vadim Kochan <vadim4j@gmail.com>
> >
> >Replaced hard coded 16384 sized netlink message buffer
> >by NL_BUF(x) macro.
> >
> >Buffer size can be overrided by -DNLBUF_SIZE.
> >
> >Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> >---
> > include/libnetlink.h | 6 ++++++
> > ip/iplink.c          | 2 +-
> > lib/libnetlink.c     | 8 ++++----
> > misc/ss.c            | 2 +-
> > 4 files changed, 12 insertions(+), 6 deletions(-)
> >
> >diff --git a/include/libnetlink.h b/include/libnetlink.h
> >index 898275b..883f581 100644
> >--- a/include/libnetlink.h
> >+++ b/include/libnetlink.h
> >@@ -170,5 +170,11 @@ extern int rtnl_from_file(FILE *, rtnl_filter_t handler,
> >  * messages from dump file */
> > #define NLMSG_TSTAMP	15
> > 
> >+#ifndef NLBUF_SIZE
> >+#define NLBUF_SIZE 16384
> >+#endif
> >+
> >+#define NL_BUF(b) char  b[NLBUF_SIZE]
> >+
> > #endif /* __LIBNETLINK_H__ */
> > 
> >diff --git a/ip/iplink.c b/ip/iplink.c
> >index 5893ee4..b9949a8 100644
> >--- a/ip/iplink.c
> >+++ b/ip/iplink.c
> >@@ -770,7 +770,7 @@ int iplink_get(unsigned int flags, char *name, __u32 filt_mask)
> > {
> > 	int len;
> > 	struct iplink_req req;
> >-	char answer[16384];
> >+	NL_BUF(answer);
> 
> Why to obfuscate this? "char answer[NLBUF_SIZE];" seems allright...
> 

Well, I thought that it would be easy to change the netlink buffer type
in the future, but may be you're right - "char answer[NLBUF_SIZE];" is
more readable anyway.

Thanks,
