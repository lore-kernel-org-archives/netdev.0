From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] iproute2: wrong error when label is more than 15
 chars
Date: Mon, 31 Mar 2014 20:48:45 -0700
Message-ID: <20140331204845.6496a28c@nehalam.linuxnetplumber.net>
References: <1395830388-13874-1-git-send-email-snagarka@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, psabata@redhat.com
To: Swapnil Nagarkar <snagarka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:34868 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbaDADst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 23:48:49 -0400
Received: by mail-pb0-f51.google.com with SMTP id uo5so9194189pbc.38
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 20:48:48 -0700 (PDT)
In-Reply-To: <1395830388-13874-1-git-send-email-snagarka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Mar 2014 16:09:48 +0530
Swapnil Nagarkar <snagarka@redhat.com> wrote:

> The string for "label" option in "ip" command does not take more than 15 chanracters.
> Gives error "RTNETLINK answers: Numerical result out of range".
> $ ip addr add 10.65.X.X/23 dev em1:1 label em1:123456789012
> RTNETLINK answers: Numerical result out of range
> $ ip addr add 10.65.X.X/23 dev em1:1 label em1:12345678901
> 
> Adding check for maximum length of interface name and proper error
> message.
> 
> After patch output:-
> $ ./ip addr replace 192.168.50.4 dev em1:123 label em1:123456789012
> Error: argument "em1:123456789012" is wrong: invalid label value.
> 
> Signed-off-by: Swapnil Nagarkar <snagarka@redhat.com>

I am not sure I like ip route commands trying to "fix up" kernel errors
like this. There are lots of possible error cases, and this one is so much
a corner case it doesn't seem right to step in and do something special.

The error number comes from the netlink attribute validation policy
and although the glibc error string is less than useful, the concept of
name too long does fit in the general meaning of ERANGE.

Unless there is a compelling outcry, I am going to reject this.
