From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sysctl: allow override of /proc/sys/net with
 CAP_NET_ADMIN
Date: Fri, 30 May 2008 19:10:53 -0700
Message-ID: <20080530191053.34182eaf@extreme>
References: <200805292349.m4TNneua029348@imap1.linux-foundation.org>
	<20080530161857.25e3fbc5@extreme>
	<m1wslbcjy9.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@linuxfoundation.org, Chris Wright <chrisw@sous-sol.org>,
	stephen.hemminger@vyatta.com, adobriyan@gmail.com,
	morgan@kernel.org, xemul@openvz.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:58385 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750730AbYEaCK7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 22:10:59 -0400
In-Reply-To: <m1wslbcjy9.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 May 2008 18:59:26 -0700
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Stephen Hemminger <shemminger@vyatta.com> writes:
> 
> > Extend the permission check for networking sysctl's to allow
> > modification when current process has CAP_NET_ADMIN capability and
> > is not root. This version uses the until now unused permissions hook
> > to override the mode value for /proc/sys/net if accessed by a user
> > with capabilities.
> 
> Looks reasonable but a little incomplete.
> 
> Could you modify register_net_sysctl_table to set this attribute?
> Or alternatively all of the tables registered with register_net_sysctl.
> 
> Otherwise I this will not affect all of the sysctls under
> /proc/sys/net.  Which appears to be your intent.
> 
> > Found while working with Quagga. It is impossible to turn forwarding
> > on/off through the command interface because Quagga uses secure coding
> > practice of dropping privledges during initialization and only raising
> > via capabilities when necessary. Since the dameon has reset real/effective
> > uid after initialization, all attempts to access /proc/sys/net variables
> > will fail. 
> 
> Eric

Unnecessary, it is a property of the root, and there is only one call to register_sysctl_root
in the current code, and that registers the net_sysctl_root structure.
