From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net v2 3/3] gre: allow creation of gretap interfaces in
 metadata mode
Date: Mon, 25 Apr 2016 11:00:35 -0700
Message-ID: <CAOrHB_BZkZhSOWqgsHXDM_3o+zkgCwRYwOL2hr33_p02if9Fxw@mail.gmail.com>
References: <cover.1461495411.git.jbenc@redhat.com>
	<4917335385a75586c1f13b6a6d570d4cc5b0b132.1461495411.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:38495 "EHLO
	slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbcDYSGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 14:06:05 -0400
Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net [217.70.183.194])
	by slow1-d.mail.gandi.net (Postfix) with ESMTP id CFDCC47EBF9
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 20:00:39 +0200 (CEST)
Received: from mfilter38-d.gandi.net (mfilter38-d.gandi.net [217.70.178.169])
	by relay2-d.mail.gandi.net (Postfix) with ESMTP id 3EC6EC5A46
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 20:00:38 +0200 (CEST)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
	by mfilter38-d.gandi.net (mfilter38-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id Fs5jZ2sSV6w8 for <netdev@vger.kernel.org>;
	Mon, 25 Apr 2016 20:00:36 +0200 (CEST)
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	(Authenticated sender: pshelar@ovn.org)
	by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 8C224C5A6A
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 20:00:36 +0200 (CEST)
Received: by mail-ig0-f177.google.com with SMTP id u10so18581548igr.1
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 11:00:36 -0700 (PDT)
In-Reply-To: <4917335385a75586c1f13b6a6d570d4cc5b0b132.1461495411.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 24, 2016 at 4:00 AM, Jiri Benc <jbenc@redhat.com> wrote:
> The IFLA_GRE_REMOTE attribute does not make sense together with collect
> metadata and is ignored in such case. However, iproute2 always sets it; it
> will be zero if there's no remote address specified on the command line.
>
> Remove the check for non-zero IFLA_GRE_REMOTE when collect medata flag is
> set.
>
Rather than cover up in ip_gre kernel module, why not just fix
iproute2 to set the attribute correctly?


> Before the patch, this command returns failure, after the patch, it works as
> expected:
>
> ip link add gre1 type gretap external
>
> Fixes: 2e15ea390e6f4 ("ip_gre: Add support to collect tunnel metadata.")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> New in v2.
> ---

>  net/ipv4/ip_gre.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
