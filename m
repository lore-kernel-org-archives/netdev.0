From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] rt2x00: improve calling conventions for register
 accessors
Date: Mon, 15 May 2017 16:28:01 +0200
Message-ID: <20170515142520.GA13996@redhat.com>
References: <20170515134711.2770374-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Helmut Schaa <helmut.schaa@googlemail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Daniel Golle <daniel@makrotopia.org>,
        Mathias Kresin <dev@kresin.me>,
        Johannes Berg <johannes.berg@intel.com>,
        Tomislav =?utf-8?Q?Po=C5=BEega?= <pozega.tomislav@gmail.com>,
        Serge Vasilugin <vasilugin@yandex.ru>,
        Roman Yeryomin <roman@advem.lv>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46704 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933222AbdEOO3y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 10:29:54 -0400
Content-Disposition: inline
In-Reply-To: <20170515134711.2770374-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 15, 2017 at 03:46:55PM +0200, Arnd Bergmann wrote:
> With CONFIG_KASAN enabled and gcc-7, we get a warning about rather high
> stack usage (with a private patch set I have to turn on this warning,
> which I intend to get into the next kernel release):
> 
> wireless/ralink/rt2x00/rt2800lib.c: In function 'rt2800_bw_filter_calibration':
> wireless/ralink/rt2x00/rt2800lib.c:7990:1: error: the frame size of 2144 bytes is larger than 1536 bytes [-Werror=frame-larger-than=]
> 
> The problem is that KASAN inserts a redzone around each local variable that
> gets passed by reference, and the newly added function has a lot of them.
> We can easily avoid that here by changing the calling convention to have
> the output as the return value of the function. This should also results in
> smaller object code, saving around 4KB in .text with KASAN, or 2KB without
> KASAN.
> 
> Fixes: 41977e86c984 ("rt2x00: add support for MT7620")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/net/wireless/ralink/rt2x00/rt2800lib.c | 319 +++++++++++++------------
>  1 file changed, 164 insertions(+), 155 deletions(-)

We have read(, &val) calling convention since forever in rt2x00 and that
was never a problem. I dislike to change that now to make some tools
happy, I think problem should be fixed in the tools instead.

Stanislaw
