From: jamal <hadi@cyberus.ca>
Subject: Re: LLTX and netif_stop_queue
Date: 28 Dec 2004 08:31:57 -0500
Message-ID: <1104240717.1100.66.camel@jzny.localdomain>
References: <52llbwoaej.fsf@topspin.com>
	<20041217214432.07b7b21e.davem@davemloft.net>
	<1103484675.1050.158.camel@jzny.localdomain>
	<5cac192f04122210491d64d4b6@mail.gmail.com>
	<20041222202919.057b8331.davem@davemloft.net>
	<5cac192f0412230110628749e3@mail.gmail.com>
	<41CAF444.3000305@trash.net>
	<5cac192f04122408102129af43@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Patrick McHardy <kaber@trash.net>,
	openib-general@openib.org, "David S. Miller" <davem@davemloft.net>
Return-path: <openib-general-bounces@openib.org>
To: Eric Lemoine <eric.lemoine@gmail.com>
In-Reply-To: <5cac192f04122408102129af43@mail.gmail.com>
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

On Fri, 2004-12-24 at 11:10, Eric Lemoine wrote:

> Yes but requiring drivers to release a lock that they should not even
> be aware of doesn't sound good. Another way would be to keep
> dev->queue_lock grabbed when entering start_xmit() and let the driver
> drop it (and re-acquire it before it returns) only if it wishes so.
> Although I don't like this too much either, that's the best way I can
> think of up to now...

I am not a big fan of that patch either, but i cant think of a cleaner
way to do it. 
The violation already happens with the LLTX flag. So maybe a big warning
that says "Do this only if you driver is LLTX enabled". The other way to
do it is put a check to see if LLTX is enabled before releasing that
lock - but why the extra cycles? Driver writer should know.

cheers,
jamal
