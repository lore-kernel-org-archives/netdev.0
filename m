From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next RFC 0/4] SO_BINDTOPREFIX
Date: Tue, 29 Mar 2016 07:31:35 -0700
Message-ID: <1459261895.6473.176.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1458699966-3752-1-git-send-email-gilberto.bertin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com, markzzzsmith@gmail.com
To: Gilberto Bertin <gilberto.bertin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:34519 "EHLO
	mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756892AbcC2Obl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 10:31:41 -0400
Received: by mail-vk0-f52.google.com with SMTP id e185so20356405vkb.1
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 07:31:40 -0700 (PDT)
In-Reply-To: <1458699966-3752-1-git-send-email-gilberto.bertin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-03-23 at 02:26 +0000, Gilberto Bertin wrote:
> Since the net-next window just opened, I'm resubmitting my RFC for the
> SO_BINDTOSUBNET patch, following Mark Smith's suggestion to rename the
> whole thing to a more clear SO_BINDTOPREFIX.

Please do not add such monolithic option.

BPF is absolutely the way to go here, as it allows for whatever user
specified tweaks, like a list of destination subnetwork, or/and a list
of source network, or the date/time of the day, or port knocking without
netfilter, or ... you name it.

Simply add an option to load a BPF filter on a socket, used to vary the
various compute_score() functions.

No hard coded knowledge in the kernel, but a generic interface.
