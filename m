From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net v2] bonding: Prevent IPv6 link local address on
 enslaved devices
Date: Mon, 11 Jan 2016 15:11:36 -0500
Message-ID: <20160111201135.GF32683@redhat.com>
References: <1452518923-9420-1-git-send-email-kheiss@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Karl Heiss <kheiss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41845 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760008AbcAKULg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2016 15:11:36 -0500
Content-Disposition: inline
In-Reply-To: <1452518923-9420-1-git-send-email-kheiss@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2016 at 08:28:43AM -0500, Karl Heiss wrote:
> Commit 1f718f0f4f97 ("bonding: populate neighbour's private on enslave")
> undoes the fix provided by commit c2edacf80e15 ("bonding / ipv6: no addrconf
> for slaves separately from master") by effectively setting the slave flag
> after the slave has been opened.  If the slave comes up quickly enough, it
> will go through the IPv6 addrconf before the slave flag has been set and
> will get a link local IPv6 address.
> 
> In order to ensure that addrconf knows to ignore the slave devices on state
> change, set IFF_SLAVE before dev_open() during bonding enslavement.
> 
> Fixes: 1f718f0f4f97 ("bonding: populate neighbour's private on enslave")
> 
> Signed-off-by: Karl Heiss <kheiss@gmail.com>
> ---
> - Changes since 'v1':
>   - Revert clearing the IFF_SLAVE flag later during bond release so that
>     RTM_NEWLINK messages will correctly reflect the slave state.
>   - Update commit message for clarity.

Looks good to me as well, and I've actually got a recent Red Hat bugzilla
report about this same issue.

Reviewed-by: Jarod Wilson <jarod@redhat.com>

-- 
Jarod Wilson
jarod@redhat.com
