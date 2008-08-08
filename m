From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: Strange tg3 regression with UMP fw. link reporting
Date: Sat, 09 Aug 2008 08:05:57 +1000
Message-ID: <1218233157.24157.343.camel@pasglop>
References: <1218180939.24157.332.camel@pasglop>
	<31233EB5-037E-4615-95C9-7C816E510752@kernel.crashing.org>
	<1218187111.24157.336.camel@pasglop>
	<20080808184359.GB23249@HP-xw6200.broadcom.net>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	Michael Chan <mchan@broadcom.com>, Nathan Lynch <ntl@pobox.com>,
	netdev <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20080808184359.GB23249@HP-xw6200.broadcom.net>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Fri, 2008-08-08 at 11:43 -0700, Matt Carlson wrote:
> 
> Segher is right.  The code should be 2.5 milliseconds but is actually
> much longer.  This fix is actually already in my patch queue and needs
> to be sent upstream.
> 
> We really shouldn't be displaying any error messages in the event of a
> timeout though.  Earlier versions of the UMP firmware did not support
> the link update interface.  The best thing the driver can do for all
> cases is give the firmware a chance to service the event but continue
> as if the event were serviced if it did not get an explicit ACK.

But that means that the driver will continuously spin 2.5ms every
timer tick or so ? Or do I miss something ? Could it be possible to
count timeouts and if after N attempts at an ack, they all timed out,
disable the feature completely ?

Or is there a way to test the version of the firmware ?

In any case, the fix should go into -stable as the problem is hurting
2.6.26. Also, should we consider updating the tg3 firmware on those
machines ?

Ben.
