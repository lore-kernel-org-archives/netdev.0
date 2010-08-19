From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Add firmware label support to iproute2
Date: Thu, 19 Aug 2010 14:53:08 -0700
Message-ID: <20100819145308.0fa08522@nehalam>
References: <20100812173537.GA29784@auslistsprd01.us.dell.com>
	<20100812141240.417949e2@s6510>
	<EDA0A4495861324DA2618B4C45DCB3EE612E34@blrx3m08.blr.amer.dell.com>
	<20100818144124.33a72453@nehalam>
	<20100819213314.GA26135@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Narendra_K@Dell.com, netdev@vger.kernel.org, Charles_Rose@Dell.com,
	Jordan_Hargrave@Dell.com
To: Matt Domsch <Matt_Domsch@Dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44586 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751191Ab0HSVxK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 17:53:10 -0400
In-Reply-To: <20100819213314.GA26135@auslistsprd01.us.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Aug 2010 16:33:14 -0500
Matt Domsch <Matt_Domsch@Dell.com> wrote:

> On Wed, Aug 18, 2010 at 02:41:24PM -0700, Stephen Hemminger wrote:
> > The netdev_alias_to_kernelname should only happen after normal lookup failed.
> 
> Stephen, can you enlighten me as to the "right" way to do interface
> name lookups?  While I can still find examples of parsing
> /proc/net/dev, or globbing /sys/class/net/*, I expect these aren't the
> preferred method anymore.  Your own iproute2 suite uses RTM_GETLINK
> netlink calls, though for the seeming simple case of "give me a list of all
> interfaces", your path through there is far more capable (and
> complex) than I would hope to need.

There is no magic right way. We have to support multiple interfaces.
I am really concerned that all this alias stuff will turn into a
disaster when there are 10,000 interfaces (Vlans).  The kernel has
lots of tables and hashes to handle this but if the utilities
are doing a dumb scan of all names it will not work.

Also burying logic in an external library seems problematic as
well. The original sysfs library was a disaster for this.
I want this to work but it has to have a simple interface that
is not trying to hide things.

