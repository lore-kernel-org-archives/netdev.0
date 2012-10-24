From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: switching network namespace midway
Date: Wed, 24 Oct 2012 14:11:14 -0700
Message-ID: <878vavshhp.fsf@xmission.com>
References: <CAFaHj6FjDULMCdta3bhVu2mtJeR9TuJVMmbC0H6jjkfb6A5t-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: rsa <ravi.mlists@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:38861 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161186Ab2JXVLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 17:11:25 -0400
In-Reply-To: <CAFaHj6FjDULMCdta3bhVu2mtJeR9TuJVMmbC0H6jjkfb6A5t-Q@mail.gmail.com>
	(rsa's message of "Tue, 23 Oct 2012 13:49:12 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rsa <ravi.mlists@gmail.com> writes:

> Assuming I have a tunnel interface where two route lookups are done --
> one for innter
> packet and the other for outer -- do you see any issues in switching
> the network
> namespace prior to second route lookup (and restore to the original namespace
> after the second lookup is done)?
>
> If so, are there any other calls other than sk_change_net() needed?

In general sk_change_net is a bad idea.

Most likely what you want to do is simply memorize both struct net's
that you care about and perform the routing lookup as appropriate.

Certainly you don't want to be calling sk_change_net for every packet
that goes through your tunnel.

Eric
