From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: need help with wireless netns crash
Date: Sat, 11 Jul 2009 13:26:45 -0700
Message-ID: <m1ocrrq83e.fsf@fess.ebiederm.org>
References: <1247302033.30647.72.camel@johannes.local>
	<m11vonsi1p.fsf@fess.ebiederm.org>
	<1247304161.30647.83.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:35304 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752849AbZGKU0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2009 16:26:50 -0400
In-Reply-To: <1247304161.30647.83.camel@johannes.local> (Johannes Berg's message of "Sat\, 11 Jul 2009 11\:22\:41 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> writes:
> From: Johannes Berg <johannes@sipsolutions.net>
> Subject: explain netns notifiers a little better
>
> Eric explained this to me -- and afterwards the comment
> made sense, but not before. Add the the critical point
> about interfaces having to be gone from the netns before
> subsys notifiers are called.
>
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> ---
>  include/net/net_namespace.h |   16 +++++++++-------
>  1 file changed, 9 insertions(+), 7 deletions(-)
>
> --- wireless-testing.orig/include/net/net_namespace.h	2009-07-11 11:18:20.000000000 +0200
> +++ wireless-testing/include/net/net_namespace.h	2009-07-11 11:20:49.000000000 +0200
> @@ -239,13 +239,15 @@ struct pernet_operations {
>   * needs per network namespace operations use device pernet operations,
>   * otherwise use pernet subsys operations.
>   *
> - * This is critically important.  Most of the network code cleanup
> - * runs with the assumption that dev_remove_pack has been called so no
> - * new packets will arrive during and after the cleanup functions have
> - * been called.  dev_remove_pack is not per namespace so instead the
> - * guarantee of no more packets arriving in a network namespace is
> - * provided by ensuring that all network devices and all sockets have
> - * left the network namespace before the cleanup methods are called.
> + * Network interfaces need to be removed from a dying netns _before_
> + * subsys notifiers can be called, as most of the network code cleanup
> + * (which is done from subsys notifiers) runs with the assumption that
> + * dev_remove_pack has been called so no new packets will arrive during
> + * and after the cleanup functions have been called.  dev_remove_pack
> + * is not per namespace so instead the guarantee of no more packets
> + * arriving in a network namespace is provided by ensuring that all
> + * network devices and all sockets have left the network namespace
> + * before the cleanup methods are called.
>   *
>   * For the longest time the ipv4 icmp code was registered as a pernet
>   * device which caused kernel oops, and panics during network

That seems like a reasonable cleanup to the wording.

Eric

