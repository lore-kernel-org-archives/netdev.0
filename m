From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 4/4] net: Add Open vSwitch kernel
	components.
Date: Fri, 18 Nov 2011 20:37:32 -0500 (EST)
Message-ID: <20111118.203732.971277374822526847.davem@davemloft.net>
References: <CAEP_g=8PjK3GWuDVT36UVxWsQsGwf1WGYXZDCdax+3XqX5-T4A@mail.gmail.com>
	<93c2cdf4-43be-4a83-88a6-8f4c8a45e581@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <93c2cdf4-43be-4a83-88a6-8f4c8a45e581-bX68f012229Xuxj3zoTs5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Date: Fri, 18 Nov 2011 17:09:17 -0800 (PST)

> =

>> On Fri, Nov 18, 2011 at 3:23 PM, Stephen Hemminger
>> <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org> wrote:
>> > On Fri, 18 Nov 2011 15:12:18 -0800
>> > Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:
>> >
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 write_seqcount_begin(&stats->seqlock);
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 stats->tx_packets++;
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 stats->tx_bytes +=3D sent;
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 write_seqcount_end(&stats->seqlock);
>> >
>> > There is a u64_stats_sync set of macros for this. It has the
>> > advantage of becoming a NOP on 64 bit platforms.
>> =

>> The reason why I did it this way is it ties the packet and byte count
>> together.
> =

> Ok, but why bother?
> No other software counters bother to group bytes/packets. Even
> hardware counters get read separately.

Agreed, this is totally pointless.  Please use the u64 state interfaces.
