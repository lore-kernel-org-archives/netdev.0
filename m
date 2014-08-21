From: Cong Wang <cwang@twopensource.com>
Subject: Re: pktgen and tos
Date: Wed, 20 Aug 2014 20:05:46 -0700
Message-ID: <CAHA+R7OKfg5C2dEz2JuxWncoo8gBX=r2MuHUdsGvALNXRSQoiQ@mail.gmail.com>
References: <53F51880.5060704@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:53127 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753345AbaHUDFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2014 23:05:48 -0400
Received: by mail-lb0-f182.google.com with SMTP id z11so7374761lbi.41
        for <netdev@vger.kernel.org>; Wed, 20 Aug 2014 20:05:46 -0700 (PDT)
In-Reply-To: <53F51880.5060704@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 20, 2014 at 2:52 PM, Ben Greear <greearb@candelatech.com> wrote:
> Here's a half-arsed bug report, in case someone is bored.
>
> At least in my hacked up pktgen, you cannot set a one-digit tos,
> because the parser fails if length is not 2 digits.
>
> echo tos 4 > /proc/net/pktgen/rddVR2 && cat /proc/net/pktgen/rddVR2
>
> ...
> Result: ERROR: tos must be 00-ff
>
> If you use '04' instead, it works.  In my case, it will be easier to hack
> user-space
> to deal with this than fix pktgen, but I thought someone might want to fix
> it proper.
>
> Also, could be that upstream code doesn't have this limitation...

We need something like this:

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 8b849dd..f8cb428 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1674,7 +1674,7 @@ static ssize_t pktgen_if_write(struct file *file,
  return len;

  i += len;
- if (len == 2) {
+ if (len <= 2) {
  pkt_dev->tos = tmp_value;
  sprintf(pg_result, "OK: tos=0x%02x", pkt_dev->tos);
  } else {
