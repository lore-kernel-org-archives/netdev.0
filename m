From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [iproute PATCH 01/12] man: Add a man page for the connmark action
Date: Mon, 7 Mar 2016 06:41:24 -0500
Message-ID: <56DD68E4.5000100@mojatatu.com>
References: <1457093507-25601-1-git-send-email-phil@nwl.cc>
 <1457093507-25601-2-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:35974 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752212AbcCGLl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 06:41:27 -0500
Received: by mail-io0-f174.google.com with SMTP id z76so26230620iof.3
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 03:41:26 -0800 (PST)
In-Reply-To: <1457093507-25601-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Phil,
Not sure how your mailer works - I am assuming these are the same
patches i got CCed on.

On 16-03-04 07:11 AM, Phil Sutter wrote:
> Cc: Felix Fietkau <nbd@openwrt.org>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>   man/man8/tc-connmark.8 | 55 ++++++++++++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 55 insertions(+)
>   create mode 100644 man/man8/tc-connmark.8
>
> diff --git a/man/man8/tc-connmark.8 b/man/man8/tc-connmark.8
> new file mode 100644
> index 0000000000000..bb4cf7543dfdb
> --- /dev/null
> +++ b/man/man8/tc-connmark.8
> @@ -0,0 +1,55 @@
> +.TH "Connmark retriever action in tc" 8 "11 Jan 2016" "iproute2" "Linux"
> +
> +.SH NAME
> +connmark - netfilter connmark retriever action
> +.SH SYNOPSIS
> +.in +8
> +.ti -8
> +.BR tc " ... " "action connmark " [ " zone"
> +.IR u16_zone_index " ] [ " BRANCH " ] ["
> +.BI index " u32_index "
> +]
> +
> +.ti -8
> +.IR BRANCH " := { " reclassify " | " pipe " | " drop " | " continue " | " ok " }"

It would be of benefit to have a general man page describing tc
actions/filters (may be one for tc action and other for tc filter).

I probably started the mess of calling this construct a "branch"
which actually is misleading.
These are controls ("if/else" are branches; a loop is not a branch).
Refer to my netdev01 paper. If you can extract details from hat paper
in a main man page or at minimal reference it in the action/classifier
man pages then the action specific man pages would just specify what
the default is.

An example usage of this from the commit message:
-----
     ...lets tag outgoing icmp with mark 0x10..
     iptables -tmangle -A PREROUTING -p icmp -j CONNMARK --set-mark 0x10
     ..add on ingress of $ETH an extractor for connmark...
     tc filter add dev $ETH parent ffff: prio 4 protocol ip \
     u32 match ip protocol 1 0xff \
     flowid 1:1 \
     action connmark continue
     ...if the connmark was 0x11, we police to a ridic rate of 10Kbps
     tc filter add dev $ETH parent ffff: prio 5 protocol ip \
     handle 0x11 fw flowid 1:1 \
     action police rate 10kbit burst 10k
----

cheers,
jamal
