From: Roland Dreier <roland@topspin.com>
Subject: Re: Re: LLTX and netif_stop_queue
Date: Sat, 18 Dec 2004 09:58:15 -0800
Message-ID: <52sm63mqtk.fsf@topspin.com>
References: <52llbwoaej.fsf@topspin.com>
	<20041217214432.07b7b21e.davem@davemloft.net>
	<528y7vobze.fsf@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <528y7vobze.fsf@topspin.com> (Roland Dreier's message of "Sat,
	18 Dec 2004 07:35:49 -0800")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    Roland> I may be missing something, but it seems to me that we get
    Roland> all of the benefits of LLTX by just documenting that
    Roland> device drivers can use the xmit_lock member of struct
    Roland> net_device to synchronize other parts of the driver
    Roland> against hard_start_xmit.  I guess the driver also should
    Roland> set xmit_lock_owner to -1 after it acquires xmit_lock.

Thinking about this a little more, I realize that there's no reason
for the driver to set xmit_lock_owner -- if the driver is able to
acquire the lock, then xmit_lock_owner will already be -1.

So it seems LLTX can be replaced by just having drivers use
net_device.xmit_lock instead of their own private tx_lock.  Assuming
this works (and I don't see anything wrong with it) then this seems
like a pretty nice solution: we remove some code from the networking
core and get rid of all the "trylock" logic in driver's hard_start_xmit.

 - Roland
