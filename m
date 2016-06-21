From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [iproute PATCH v2 2/7] Use C99 style initializers everywhere
Date: Tue, 21 Jun 2016 10:24:37 -0600
Message-ID: <726e5c7d-f23b-dbf0-c1d4-721ef3d15d5b@cumulusnetworks.com>
References: <1466525921-15738-1-git-send-email-phil@nwl.cc>
 <1466525921-15738-3-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33135 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbcFUQYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 12:24:43 -0400
Received: by mail-pf0-f176.google.com with SMTP id i123so8120535pfg.0
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 09:24:42 -0700 (PDT)
In-Reply-To: <1466525921-15738-3-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/21/16 10:18 AM, Phil Sutter wrote:
> This big patch was compiled by vimgrepping for memset calls and changing
> to C99 initializer if applicable. One notable exception is the
> initialization of union bpf_attr in tc/tc_bpf.c: changing it would break
> for older gcc versions (at least <=3.4.6).
>
> Calls to memset for struct rtattr pointer fields for parse_rtattr*()
> were just dropped since they are not needed.
>
> The changes here allowed the compiler to discover some unused variables,
> so get rid of them, too.
>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
> Changes since v1:
> - Dropped former changes to tc/tc_bpf.c as they are incompatible to older
>   gcc versions (at least <=3.4.6).


What OS versions have you compiled iproute2 against?

I downloaded CentOS 5 and 6. iproute2 fails to compile on CentOS 5.11; 
ip command builds on 6.8 but with a flurry of redefinition errors 
(BUILD_BUG_ON), but fails at tc.
