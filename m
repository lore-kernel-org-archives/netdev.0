From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] sysctl: allow override of /proc/sys/net with CAP_NET_ADMIN
Date: Fri, 30 May 2008 18:59:26 -0700
Message-ID: <m1wslbcjy9.fsf@frodo.ebiederm.org>
References: <200805292349.m4TNneua029348@imap1.linux-foundation.org>
	<20080530161857.25e3fbc5@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linuxfoundation.org, Chris Wright <chrisw@sous-sol.org>,
	stephen.hemminger@vyatta.com, adobriyan@gmail.com,
	morgan@kernel.org, xemul@openvz.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:49052 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbYEaCBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 22:01:01 -0400
In-Reply-To: <20080530161857.25e3fbc5@extreme> (Stephen Hemminger's message of
	"Fri, 30 May 2008 16:18:57 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> Extend the permission check for networking sysctl's to allow
> modification when current process has CAP_NET_ADMIN capability and
> is not root. This version uses the until now unused permissions hook
> to override the mode value for /proc/sys/net if accessed by a user
> with capabilities.

Looks reasonable but a little incomplete.

Could you modify register_net_sysctl_table to set this attribute?
Or alternatively all of the tables registered with register_net_sysctl.

Otherwise I this will not affect all of the sysctls under
/proc/sys/net.  Which appears to be your intent.

> Found while working with Quagga. It is impossible to turn forwarding
> on/off through the command interface because Quagga uses secure coding
> practice of dropping privledges during initialization and only raising
> via capabilities when necessary. Since the dameon has reset real/effective
> uid after initialization, all attempts to access /proc/sys/net variables
> will fail. 

Eric
