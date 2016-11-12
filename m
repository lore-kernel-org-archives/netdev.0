From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v4] iproute2: macvlan: add "source" mode
Date: Sat, 12 Nov 2016 10:12:33 +0300
Message-ID: <20161112101233.0d0369ea@samsung9>
References: <1477565076-18968-1-git-send-email-michael-dev@fami-braun.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, projekt-wlan@fem.tu-ilmenau.de,
        steweg@gmail.com
To: Michael Braun <michael-dev@fami-braun.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:32915 "EHLO
        mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751003AbcKLHVg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2016 02:21:36 -0500
Received: by mail-lf0-f41.google.com with SMTP id c13so26694836lfg.0
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 23:21:35 -0800 (PST)
In-Reply-To: <1477565076-18968-1-git-send-email-michael-dev@fami-braun.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Oct 2016 12:44:36 +0200
Michael Braun <michael-dev@fami-braun.de> wrote:

> Adjusting iproute2 utility to support new macvlan link type mode called
> "source".
> 
> Example of commands that can be applied:
>   ip link add link eth0 name macvlan0 type macvlan mode source
>   ip link set link dev macvlan0 type macvlan macaddr add 00:11:11:11:11:11
>   ip link set link dev macvlan0 type macvlan macaddr del 00:11:11:11:11:11
>   ip link set link dev macvlan0 type macvlan macaddr flush
>   ip -details link show dev macvlan0
> 
> Based on previous work of Stefan Gula <steweg@gmail.com>
> 
> Signed-off-by: Michael Braun <michael-dev@fami-braun.de>
> 
> Cc: steweg@gmail.com
> 
> v4:
>  - add MACADDR_SET support
>  - skip FLAG_UNICAST / FLAG_UNICAST_ALL as this is not upstream
>  - fix man page

The patch looks good, but needs to be cleaned up.

Does not apply to current iproute2 git, and also has minor checkpatch issue.

--- ip/iplink_macvlan.c
+++ ip/iplink_macvlan.c
@@ -46,7 +51,14 @@ static void explain(struct link_util *lu)
 
 static int mode_arg(const char *arg)
 {
-        fprintf(stderr, "Error: argument of \"mode\" must be \"private\", \"vepa\", \"bridge\" or \"passthru\", not \"%s\"\n",
+	fprintf(stderr, "Error: argument of \"mode\" must be \"private\", \"vepa\", \"bridge\", \"passthru\" or \"source\", not \"%s\"\n",
+		arg);
+	return -1;
+}
+
+static int flag_arg(const char *arg)
+{
+	fprintf(stderr, "Error: argument of \"flag\" must be \"nopromisc\" or \"null\", not \"%s\"\n",
 		arg);
 	return -1;
 }


WARNING: unnecessary whitespace before a quoted newline
#59: FILE: ip/iplink_macvlan.c:35:
+		"MODE_FLAG: null | nopromisc \n"
