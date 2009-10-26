From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [PATCH] PPPoE: Fix flush/close races.
Date: Mon, 26 Oct 2009 22:05:37 +0200
Message-ID: <200910262205.38108.denys@visp.net.lb>
References: <1256586498-6230-1-git-send-email-mostrows@gmail.com> <e6d1cecd0910261251w721b8258n7dfc1bac9d01af8b@mail.gmail.com> <20091026195933.GC5321@lenovo>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Michal Ostrowski <mostrows@gmail.com>, linux-ppp@vger.kernel.org,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20091026195933.GC5321@lenovo>
Content-Disposition: inline
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 26 October 2009 21:59:33 Cyrill Gorcunov wrote:
> [Michal Ostrowski - Mon, Oct 26, 2009 at 02:51:52PM -0500]
>
> | Be more careful about the state of pointers during tear-down.
> | The "pppoe_dev" field can only be looked at safely while holding socket
> | locks. This subsequently allows for the flush_lock to be killed.
> |
> | We depend on the PPPOX_CONNECTED state to tell us that that those fields
> | are valid, so whoever clears that state (pppox_unbind_sock()) is
> | responsible for the dev_put() call.
> |
> | We also have to ensure that we delete_item() on all sockets before they
> | are cleaned up.
> |
> | The need for these changes has been exposed by scenarios wherein
> | namespace bindings of ethernet devices change while there are ongoing
> | PPPoE sessions, which resulted in oopses due to unusual socket connection
> | termination paths, exposing these issues.
> |
> | Signed-off-by: Michal Ostrowski <mostrows@gmail.com>
> | Reviewed-by: Cyril Gorcunov <gorcunov@gmail.com>
>
> ...
>
> Thanks a lot Michal!
>
> I think we should add as well
>
> Reported-by: Denys Fedoryschenko <denys@visp.net.lb>
> Tested-by: Denys Fedoryschenko <denys@visp.net.lb>
>
> 	-- Cyrill

Yes, till now everything working perfectly. Confirming :-)
