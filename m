From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net,
	bridge: print log message after state changed
Date: Mon, 14 Nov 2011 02:07:49 -0500 (EST)
Message-ID: <20111114.020749.1176229013272872343.davem@davemloft.net>
References: <1320941934-3534-1-git-send-email-holger.brunck@keymile.com>
	<20111114.003702.1097206603722725705.davem@davemloft.net>
	<1321254211.4072.29.camel@pc005091.de.keymile.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	bridge@lists.linux-foundation.org, holger.brunck@keymile.com
To: Wolfgang.Fritz@keymile.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1321254211.4072.29.camel@pc005091.de.keymile.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: "Fritz, Wolfgang" <Wolfgang.Fritz@keymile.com>
Date: Mon, 14 Nov 2011 08:03:31 +0100

> 
> Am Montag, den 14.11.2011, 00:37 -0500 schrieb David Miller:
>> From: Holger Brunck <holger.brunck@keymile.com>
>> Date: Thu, 10 Nov 2011 17:18:54 +0100
>> 
>> > From: Wolfgang Fritz <wolfgang.fritz@keymile.com>
>> > 
>> > Function br_log_state writes log message "... entering XXXX state" so it
>> > should be called after the state has changed and not before.
>> > 
>> > Signed-off-by: Wolfgang Fritz <wolfgang.fritz@keymile.com>
>> > Signed-off-by: Holger Brunck <holger.brunck@keymile.com>
>> 
>> "entering" can roughly mean "about to enter"
>> 
> 
> Exactly.
> 
>> The message is therefore appropriately timed as far as I'm concerned.
>> 
> 
> It's not.
> 
> Please test: create a bridge with STP disabled, add an interface to the
> bridge and set that interface down. You get the message "... entering
> forwarding state". That's wrong because it's "about to enter" disabled
> state some lines later.
> 
> All other (4) calls to br_log_state are located after the state change,
> see for example br_stp_enable_port() just some lines above the patch.

I would never expect an "entering" message to print out after the event
happens, and in fact I'd _always_ want to see it beforehand so that if
the state change caused a crash or similar it'd be that much easier
to pinpoint the proper location.

I'm still not applying this.  If the other log messages behave
differently, they are broken, so go fix those instead.
