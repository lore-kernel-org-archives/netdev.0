From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net v5 1/5] bnx2x: protect different statistics flows
Date: Mon, 12 Aug 2013 17:12:08 -0700
Message-ID: <20130812171208.7dde2569@nehalam.linuxnetplumber.net>
References: <1376349903-3461-1-git-send-email-dmitry@broadcom.com>
	<1376349903-3461-2-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com,
	"Ariel Elior" <ariele@broadcom.com>
To: "Dmitry Kravkov" <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:63926 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756142Ab3HMAMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 20:12:12 -0400
Received: by mail-pb0-f51.google.com with SMTP id jt11so419768pbb.38
        for <netdev@vger.kernel.org>; Mon, 12 Aug 2013 17:12:12 -0700 (PDT)
In-Reply-To: <1376349903-3461-2-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Aug 2013 02:24:59 +0300
"Dmitry Kravkov" <dmitry@broadcom.com> wrote:

> +	bool					stats_started;
> +	struct semaphore			stats_sema;

Is there a reason to use a counting semaphore? Do you expect it to
be held across user process boundary? or want count > 1?

Use of semaphores as a locking primitive is discouraged,
instead us a mutex.
