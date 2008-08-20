From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] forcedeth: Fix kexec regression
Date: Wed, 20 Aug 2008 00:01:33 -0700
Message-ID: <m1od3ow4oi.fsf@frodo.ebiederm.org>
References: <1218954333-12819-1-git-send-email-yhlu.kernel@gmail.com>
	<200808190008.54743.rjw@sisk.pl>
	<86802c440808181536j2c214cc3k47e73fd147b4fee1@mail.gmail.com>
	<200808192045.54779.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Jeff Garzik" <jgarzik@redhat.com>,
	David Miller <davem@davemloft.net>,
	"Yinghai Lu" <yhlu.kernel@gmail.com>,
	"Ingo Molnar" <mingo@elte.hu>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	"Jesse Barnes" <jbarnes@virtuousgeek.org>,
	"Simon Arlott" <simon@fire.lp0.eu>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58238 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854AbYHTHEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 03:04:02 -0400
In-Reply-To: <200808192045.54779.rjw@sisk.pl> (Rafael J. Wysocki's message of
	"Tue, 19 Aug 2008 20:45:53 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Rafael J. Wysocki" <rjw@sisk.pl> writes:

> From: Rafael J. Wysocki <rjw@sisk.pl>
>
> forcedeth: Fix kexec regression
>
> Fix regression tracked as
> http://bugzilla.kernel.org/show_bug.cgi?id=11361 and
> caused by commit f735a2a1a4f2a0f5cd823ce323e82675990469e2
> ("[netdrvr] forcedeth: setup wake-on-lan before shutting down")
> that makes network adapters integrated into the NVidia
> MCP55 chipsets fail to work in kexeced kernels.  The problem appears
> to be that if the adapter is put into D3_hot during ->shutdown(),
> it cannot be brought back into D0 after kexec (ref.
> http://marc.info/?l=linux-kernel&m=121900062814967&w=4).  Therefore,
> only put forcedeth into D3 during ->shutdown() if the system is to be
> powered off.

Any chance we can fix this by teaching the forcedeth driver to
bring a card out of PCI_D3hot?

The kexec on panic guys are going to need that and it is just generally
more robust all of the way around than a special case in shutdown
based on system_state.

Eric
