From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2 2/2] iplink: print out addrgenmode attribute
Date: Tue, 6 Jan 2015 18:08:36 +0100
Message-ID: <20150106170836.GA1921@nanopsycho.orion>
References: <1420561426-3118-1-git-send-email-jiri@resnulli.us>
 <1420561426-3118-2-git-send-email-jiri@resnulli.us>
 <1420563153.2527.14.camel@hal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: Thomas Haller <thaller@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:38031 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752073AbbAFRIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 12:08:39 -0500
Received: by mail-wg0-f54.google.com with SMTP id z12so11891045wgg.27
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 09:08:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1420563153.2527.14.camel@hal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jan 06, 2015 at 05:52:33PM CET, thaller@redhat.com wrote:
>On Tue, 2015-01-06 at 17:23 +0100, Jiri Pirko wrote:
>> addrgenmode is currently write only by ip. So display this information
>> if provided by kernel as well.
>
>>  
>> +static void print_af_spec(FILE *fp, struct rtattr *af_spec_attr)
>> +{
>> +	struct rtattr *inet6_attr;
>> +	struct rtattr *tb[IFLA_INET6_MAX + 1];
>> +
>> +	inet6_attr = parse_rtattr_one_nested(AF_INET6, af_spec_attr);
>> +	if (!inet6_attr)
>> +		return;
>> +
>> +	parse_rtattr_nested(tb, IFLA_INET6_MAX, inet6_attr);
>> +
>> +	if (tb[IFLA_INET6_ADDR_GEN_MODE]) {
>> +		switch (rta_getattr_u8(tb[IFLA_INET6_ADDR_GEN_MODE])) {
>> +		case IN6_ADDR_GEN_MODE_EUI64:
>> +			fprintf(fp, "addrgenmode eui64 ");
>
>eui64 is the default and the behavior of older kernels.
>
>I dunno, would it be better not to print the default case?


This prints only when show_details is on. So I believe it is ok to print
the default value of addrgenmode (same is done as for other things)
