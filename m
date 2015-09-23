From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v7 02/10] ss: created formatters for json and hr
Date: Wed, 23 Sep 2015 16:26:50 -0700
Message-ID: <20150923162650.148fe95b@urahara>
References: <1441913708-15532-1-git-send-email-matthias.tafelmeier@gmx.net>
	<1441913708-15532-3-git-send-email-matthias.tafelmeier@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hagen@jauu.net, shemminger@osdl.org,
	fw@strlen.de, edumazet@google.com, daniel@iogearbox.net
To: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36838 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755946AbbIWX0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 19:26:39 -0400
Received: by pacgz1 with SMTP id gz1so3881322pac.3
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 16:26:38 -0700 (PDT)
In-Reply-To: <1441913708-15532-3-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Having JSON output is going to be a real plus for programatic parsing.
My understanding of best practice with JSON is that it is best to output values
in best machine readable form, the format is not really meant for humans to
directly read.

Therefore I don't like the code that reformats numbers as hex.
If the values are better displayed in hex, then it is up to the program
parsing and presenting that to the user to do that. The JSON should
just put out numeric values as numeric.

> +/* hex conversion helper */
> +static void jsonw_hex_as_str_outp(json_writer_t *self, uint64_t num)
> +{
> +	char tmp[17];
> +
> +	sprintf(tmp, "%"PRIx64, num);
> +	jsonw_string(self, tmp);
> +}
> +
> +static void jsonw_hex_field_outp(json_writer_t *self, const char *prop, uint64_t num)
> +{
> +	jsonw_name(self, prop);
> +	jsonw_hex_as_str_outp(self, num);
> +}
> +

Other than that, my only other discomfort is that this patch set
makes the code grow so much larger and it becomes more complex for future
developers.

Maybe it is time to rewrite it in a better language ;-)
