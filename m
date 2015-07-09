From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2] iproute2: ipa: show switch id
Date: Thu, 9 Jul 2015 08:11:25 +0200
Message-ID: <20150709061125.GC2270@nanopsycho.orion>
References: <1436368098-21358-1-git-send-email-jiri@resnulli.us>
 <559D9646.8090203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:36720 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbbGIGL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 02:11:28 -0400
Received: by wgxm20 with SMTP id m20so30517982wgx.3
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 23:11:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <559D9646.8090203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jul 08, 2015 at 11:29:42PM CEST, dsahern@gmail.com wrote:
>On 7/8/15 9:08 AM, Jiri Pirko wrote:
>>We forgot to include this patch somehow. So do it now.
>>
>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>---
>>  ip/ipaddress.c | 8 ++++++++
>>  1 file changed, 8 insertions(+)
>>
>>diff --git a/ip/ipaddress.c b/ip/ipaddress.c
>>index 85a81ba..b7b4e3e 100644
>>--- a/ip/ipaddress.c
>>+++ b/ip/ipaddress.c
>>@@ -688,6 +688,14 @@ int print_linkinfo(const struct sockaddr_nl *who,
>>  				      b1, sizeof(b1)));
>>  	}
>>
>>+	if (tb[IFLA_PHYS_SWITCH_ID]) {
>>+		SPRINT_BUF(b1);
>>+		fprintf(fp, "switchid %s ",
>>+			hexstring_n2a(RTA_DATA(tb[IFLA_PHYS_SWITCH_ID]),
>>+				      RTA_PAYLOAD(tb[IFLA_PHYS_SWITCH_ID]),
>>+				      b1, sizeof(b1)));
>>+	}
>>+
>>  	if (tb[IFLA_OPERSTATE])
>>  		print_operstate(fp, rta_getattr_u8(tb[IFLA_OPERSTATE]));
>>
>>
>
>Do Stephen's comments about port-name apply here?
>   http://www.spinics.net/lists/netdev/msg322693.html
>
>I was wondering if this should go into -details output rather than the
>default.

I would like to have this in default. It is very important info for user
who has switch device. He should see this right away.
