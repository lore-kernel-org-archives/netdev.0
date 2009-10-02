From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: query: adding a sysctl
Date: Thu, 1 Oct 2009 22:57:05 -0700
Message-ID: <20091001225705.788d38ba@nehalam>
References: <4AC57AC5.3080703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60919 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756692AbZJBF5H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Oct 2009 01:57:07 -0400
In-Reply-To: <4AC57AC5.3080703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 02 Oct 2009 00:00:05 -0400
William Allen Simpson <william.allen.simpson@gmail.com> wrote:

> [My first post here, hopefully not a FAQ, as I've googled it, but cannot find
> the definitive answer.]
> 
> I've been trying to add a sysctl, and I've noticed this message:
> 
> sysctl table check failed: /net/ipv4/tcp_cookie_size .3.5.126 Unknown sysctl binary path
> 
> I modeled the code on sysctl_tcp_syncookies, and apparently I'm missing some
> additional magic?  Or does something need to be done other than C?

The sysctl table check code is kernel/sysctl.c, it maps numerical
sysctl values to /proc paths so that the permissions checks on the numeric
sysctl match those of the /proc file involved.

Hint: the easiest way to find things out is to use git grep
to see how any related sysctl is implemented.

BUT numbered sysctl values are deprecated and should no longer be added.
The current way is to use CTL_UNNUMBERED instead, if you use CTL_UNNUMBERED
then the table does not need to be changed.

-- 
