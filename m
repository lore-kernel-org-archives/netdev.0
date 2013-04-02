From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch 2/2] qeth: fix qeth_wait_for_threads() deadlock for OSN
 devices
Date: Tue, 02 Apr 2013 09:13:48 -0700
Message-ID: <1364919228.5113.178.camel@edumazet-glaptop>
References: <20130402105650.056630101@de.ibm.com>
	 <20130402105707.222865335@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, Stefan Raspl <raspl@linux.vnet.ibm.com>
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:55781 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761063Ab3DBQNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 12:13:51 -0400
In-Reply-To: <20130402105707.222865335@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-02 at 12:56 +0200, frank.blaschka@de.ibm.com wrote:
> plain text document attachment (602-qeth-thread-deadlock.diff)
> From: Stefan Raspl <raspl@linux.vnet.ibm.com>

> +static bool qeth_is_recovery_task(struct qeth_card *card)
> +{
> +	return (card->recovery_task == current);
> +}
> +

static bool qeth_is_recovery_task(const struct qeth_card *card)
{
	return card->recovery_task == current;
}
