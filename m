From: Lars Ellenberg <lars.ellenberg-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v3] block/drbd: align properly u64
 in nl messages
Date: Tue, 10 May 2016 11:40:23 +0200
Message-ID: <20160510094023.GC16459@soda.linbit>
References: <20160503100644.GE16459@soda.linbit>
	<1462786820-15519-1-git-send-email-nicolas.dichtel@6wind.com>
	<20160509131547.GX16459@soda.linbit> <5731A561.6090509@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, philipp.reisner-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org
To: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Return-path: <drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5731A561.6090509-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://lists.linbit.com/mailman/options/drbd-dev>,
	<mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linbit.com/pipermail/drbd-dev>
List-Post: <mailto:drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>
List-Help: <mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=help>
List-Subscribe: <http://lists.linbit.com/mailman/listinfo/drbd-dev>,
	<mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=subscribe>
Sender: drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
Errors-To: drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 10, 2016 at 11:09:53AM +0200, Nicolas Dichtel wrote:
> Le 09/05/2016 15:15, Lars Ellenberg a =E9crit :
> > On Mon, May 09, 2016 at 11:40:20AM +0200, Nicolas Dichtel wrote:
> [snip]
> >> Maybe prefixing genl_magic_func.h and genl_magic_struct.h by 'drbd_'
> >> could be interesting so that new module won't use it. What is your
> >> opinion?
> > =

> > This was supposed to not be DRBD specific.  But it might even still
> > need some massaging before it was truly generic. And obviously,
> > it does not meet the taste of genetlink folks, to say the least :(
> Yes, this file is not generic and netlink APIs are never defined like thi=
s.
> These tons of macro complexifies the code too much. It's overengineering =
for
> what purpose?

If we introduce a new config option,
we have to add it to the config scanner (one line),
define min, max, default and scale (four short defines),
and add it to the netlink definition here (one line).
Done, rest of the code is generated,
both on the kernel side,
and on the drbd-utils side used to talk to the kernel.
We found that to be very convenient.

> Small examples:
>  - the drbd netlink API is not exported via uapi (I wonder how apps using=
 this
>    API get it)

There used to be a time where there was no "uapi".
(I wonder how apps ever worked back then).

>  - v2 of the patch is nacked because adding a new attribute may break exi=
sting

No.

But because the "new" attributes you chose have not been new,
but already used (though not yet merged back into mainline yet).
(Which you did not realize, and had no obvious way of knowing.
 Could have been fixed.).

And because your patch introduced useless new members to the structs.
(Could also have been fixed).

And because I did not see any use defining that many new "padding attribute=
s"
for no reason, where the obvious (to me) choice was to use 0, and you
did not even try to explain why that would have been a bad choice.

>    apps (in networking code, a lot of new attributes are added in each ve=
rsion)


>  - it's not possible to grep to show the definition of an attribute ('git=
 grep
>    -w T_bits_total' returns only 1 line)

Opencoded, it would return 2.

 ;-)

Is this going somewhere?

Cheers,

    Lars
