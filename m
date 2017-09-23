From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v2 1/6] selftests: rtnetlink.sh: add rudimentary
 vrf test
Date: Sat, 23 Sep 2017 11:07:58 -0600
Message-ID: <aec1997f-a2bb-04ae-a089-694344d7faa5@gmail.com>
References: <20170922061008.14723-1-fw@strlen.de>
 <20170922061008.14723-2-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:45708 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750778AbdIWRIA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 13:08:00 -0400
Received: by mail-pf0-f179.google.com with SMTP id z84so1924586pfi.2
        for <netdev@vger.kernel.org>; Sat, 23 Sep 2017 10:08:00 -0700 (PDT)
In-Reply-To: <20170922061008.14723-2-fw@strlen.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/22/17 12:10 AM, Florian Westphal wrote:
> +kci_test_vrf()
> +{
> +	vrfname="test-vrf"
> +	ret=0
> +
> +	ip link show type vrf 2>/dev/null
> +	if [ $? -ne 0 ]; then
> +		echo "SKIP: vrf: iproute2 too old"
> +		return 0
> +	fi
> +
> +	ip link add "$vrfname" type vrf table 10
> +	check_err $?
> +	if [ $ret -ne 0 ];then
> +		echo "FAIL: can't add vrf interface, skipping test"
> +		return 0
> +	fi
> +
> +	ip -br link show type vrf | grep -q "$vrfname"
> +	check_err $?
> +	if [ $ret -ne 0 ];then
> +		echo "FAIL: created vrf device not found"
> +		return 1
> +	fi
> +
> +        ip link set dev "$vrfname" up

BTW, if there is a v3 of this set, that ip command is shifted - uses
spaces instead of tab.
