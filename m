From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] net: Fix running without sysfs
Date: Wed, 26 Sep 2007 17:07:14 -0700
Message-ID: <20070926170714.04afe275@freepuppy.rosehill>
References: <m1zlz9rnt1.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34936 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751301AbXI0AHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 20:07:19 -0400
In-Reply-To: <m1zlz9rnt1.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 26 Sep 2007 17:48:10 -0600
ebiederm@xmission.com (Eric W. Biederman) wrote:

> 
> When sysfs support is compiled out the kernel still keeps and maintains
> the kobject tree.  So it is not safe to skip our kobject reference counting or 
> to avoid becoming members of the kobject tree.  It is safe to not add
> the networking specific sysfs attributes.
> 
> This patch removes the sysfs special cases from net/core/dev.c
> renames functions from netdev_sysfs_xxxx to netdev_kobject_xxxx
> and always compiles in net-sysfs.c
> 
> net-sysfs.c is modified with a CONFIG_SYSFS guard around the parts
> that are actually sysfs specific.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Acked-by: Stephen Hemminger <shemminger@linux-foundation.org>

Looks good. It also fixes a use after-free in netdev_run_todo
when !CONFIG_SYSFS

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
