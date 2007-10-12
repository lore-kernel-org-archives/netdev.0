From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 03/12] Prevent renaming interfaces to empty string.
Date: Fri, 12 Oct 2007 14:01:13 +0200
Message-ID: <470F6209.6020708@trash.net>
References: <1192179407-22461-1-git-send-email-andreas@fatal.se> <1192179407-22461-2-git-send-email-andreas@fatal.se> <1192179407-22461-3-git-send-email-andreas@fatal.se>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040603040002030806060301"
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	Alexander Wirt <formorer@debian.org>
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56319 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755006AbXJLMBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 08:01:48 -0400
In-Reply-To: <1192179407-22461-3-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040603040002030806060301
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Andreas Henriksson wrote:
> From: Alexander Wirt <formorer@debian.org>
> 
> 
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>
> ---
>  ip/iplink.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/ip/iplink.c b/ip/iplink.c
> index 4060845..da1f64e 100644
> --- a/ip/iplink.c
> +++ b/ip/iplink.c
> @@ -670,6 +670,10 @@ static int do_set(int argc, char **argv)
>  	}
>  
>  	if (newname && strcmp(dev, newname)) {
> +		if (strlen(newname) == 0) {
> +		    printf("\"\" is not valid device identifier\n");
> +		    return -1;
> +		}


Indentation fixed, same change for the non-ioctl case, use invarg.
While I'm at it I also fixed the error message for "name too long",
*argv is NULL at this point.

Signed-off-by: Patrick McHardy <kaber@trash.net>


--------------040603040002030806060301
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/ip/iplink.c b/ip/iplink.c
index 4060845..8e0ed2a 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -336,8 +336,10 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 
 	if (name) {
 		len = strlen(name) + 1;
+		if (len == 1)
+			invarg("\"\" is not a valid device identifier\n", "name");
 		if (len > IFNAMSIZ)
-			invarg("\"name\" too long\n", *argv);
+			invarg("\"name\" too long\n", name);
 		addattr_l(&req.n, sizeof(req), IFLA_IFNAME, name, len);
 	}
 
@@ -670,6 +672,8 @@ static int do_set(int argc, char **argv)
 	}
 
 	if (newname && strcmp(dev, newname)) {
+		if (strlen(newname) == 0)
+			invarg("\"\" is not a valid device identifier\n", "name");
 		if (do_changename(dev, newname) < 0)
 			return -1;
 		dev = newname;

--------------040603040002030806060301--
