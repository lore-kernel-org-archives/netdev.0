From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] iproute2: add libgenl files
Date: Mon, 10 Sep 2012 15:42:43 -0700
Message-ID: <20120910154243.215fbcab@nehalam.linuxnetplumber.net>
References: <1347097705-2906-1-git-send-email-ja@ssi.bg>
	<1347097705-2906-2-git-send-email-ja@ssi.bg>
	<20120910095518.59ddae61@nehalam.linuxnetplumber.net>
	<alpine.LFD.2.00.1209110021150.2010@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51911 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753766Ab2IJWnW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 18:43:22 -0400
In-Reply-To: <alpine.LFD.2.00.1209110021150.2010@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Sep 2012 00:54:00 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> > Why not an inline function, macro code is error prone.  
> 
> 	The problem is that we define every request with
> its own structure in GENL_DEFINE_REQUEST. We can use init
> func instead of macro only if we define some base structure,
> for example:
> 
> struct genl_header_base {
> 	struct nlmsghdr		n;
> 	struct genlmsghdr	g;
> };

Ok, that makes sense. I prefer C99 style initializers
in general. Maybe:

#define GENL_INIT_REQUEST(family, hdrsize, ver, cmd_, flags) {	\
	.req = { \
          .n = { \
             .nlmsg_type = (family), \
             .nlmsg_flags = (flags), \
             .nlmsg_len   = NLMSG_LENGTH(GENL_HDRLEN + (hdrsize)), \
           } \
          .g = { \
              .cmd = (cmd), \
              .version = (ver), \
           } \
          }
		

Or merge GENL_DEFINE_REQUEST and GENL_INIT_REQUEST.

These are all nits, and not that important, just want to make it as simple
as possible. So if you like it okay as it was, we can just use that.
