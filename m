From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH] Really fix get_addr() and get_prefix() error
 messages
Date: Thu, 3 Aug 2017 16:02:07 -0700
Message-ID: <20170803160207.0839d387@xeon-e3>
References: <20170801163611.10094-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:32938 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751865AbdHCXCK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 19:02:10 -0400
Received: by mail-pf0-f172.google.com with SMTP id d67so565874pfc.0
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 16:02:10 -0700 (PDT)
In-Reply-To: <20170801163611.10094-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  1 Aug 2017 18:36:11 +0200
Phil Sutter <phil@nwl.cc> wrote:

> Both functions take the desired address family as a parameter. So using
> that to notify the user what address family was expected is correct,
> unlike using dst->family which will tell the user only what address
> family was specified.
> 
> The situation which commit 334af76143368 tried to fix was when 'ip'
> would accept addresses from multiple families. In that case, the family
> parameter is set to AF_UNSPEC so that get_addr_1() may accept any valid
> address.
> 
> This patch introduces a wrapper around family_name() which returns the
> string "any valid" for AF_UNSPEC instead of the three question marks
> unsuitable for use in error messages.
> 
> Tests for AF_UNSPEC:
> 
> | # ip a a 256.10.166.1/24 dev d0
> | Error: any valid prefix is expected rather than "256.10.166.1/24".
> 
> | # ip neighbor add proxy 2001:db8::g dev d0
> | Error: any valid address is expected rather than "2001:db8::g".
> 
> Tests for explicit address family:
> 
> | # ip -6 addrlabel add prefix 1.1.1.1/24 label 123
> | Error: inet6 prefix is expected rather than "1.1.1.1/24".
> 
> | # ip -4 addrlabel add prefix dead:beef::1/24 label 123
> | Error: inet prefix is expected rather than "dead:beef::1/24".
> 
> Reported-by: Jaroslav Aster <jaster@redhat.com>
> Fixes: 334af76143368 ("fix get_addr() and get_prefix() error messages")
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Moderately more helpful, so sure.
