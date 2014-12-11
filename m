From: vadim4j@gmail.com
Subject: Re: [PATCH iproute2 v2] ip: Simplify executing ip cmd within network
 ns
Date: Thu, 11 Dec 2014 16:34:09 +0200
Message-ID: <20141211143409.GA9877@angus-think.wlc.globallogic.com>
References: <1418305103-5994-1-git-send-email-vadim4j@gmail.com>
 <20141211142131.GC1912@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:43704 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757040AbaLKOoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 09:44:01 -0500
Received: by mail-la0-f49.google.com with SMTP id hs14so4315277lab.22
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 06:44:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141211142131.GC1912@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 11, 2014 at 03:21:31PM +0100, Jiri Pirko wrote:
> Thu, Dec 11, 2014 at 02:38:23PM CET, vadim4j@gmail.com wrote:
> >From: Vadim Kochan <vadim4j@gmail.com>
> >
> >Added new '-netns' option to simplify executing following cmd:
> >
> >    ip netns exec NETNS ip OPTIONS COMMAND OBJECT
> >
> >    to
> >
> >    ip -n[etns] NETNS OPTIONS COMMAND OBJECT
> >
> >e.g.:
> >
> >    ip -net vnet0 link add br0 type bridge
> >    ip -n vnet0 link
> >
> >Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> >---
> >Changes v1 -> v2
> >    use -n[etns] option name: suggested by Nicolas Dichtel
> >    changed man ip.8 page
> >
> > ip/ip.c        |  6 ++++++
> > ip/ip_common.h |  1 +
> > ip/ipnetns.c   |  2 +-
> > man/man8/ip.8  | 24 +++++++++++++++++++++++-
> > 4 files changed, 31 insertions(+), 2 deletions(-)
> >
> >diff --git a/ip/ip.c b/ip/ip.c
> >index 5f759d5..f3c2cdb 100644
> >--- a/ip/ip.c
> >+++ b/ip/ip.c
> >@@ -262,6 +262,12 @@ int main(int argc, char **argv)
> > 			rcvbuf = size;
> > 		} else if (matches(opt, "-help") == 0) {
> > 			usage();
> >+		} else if (matches(opt, "-netns") == 0) {
> >+			argc--;
> >+			argv++;
> >+			argv[0] = argv[1];
> >+			argv[1] = basename;
> >+			return netns_exec(argc, argv);
> 

Hi,

> 
> Can't the same functionality be done in the same ip process, meaning
> without execvp ip again? It would seem clearer to me.
> 
Hm, yes, I will look on this ...

> How about other tools (tc,bridge,..) ? It would be nice to have the same
> option there as well.
> 
Sure, good idea, I will try.

Thanks,
