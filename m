From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v3] block/drbd: align properly u64
	in nl messages
Date: Tue, 10 May 2016 11:09:53 +0200
Message-ID: <5731A561.6090509@6wind.com>
References: <20160503100644.GE16459@soda.linbit>
	<1462786820-15519-1-git-send-email-nicolas.dichtel@6wind.com>
	<20160509131547.GX16459@soda.linbit>
Reply-To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, philipp.reisner-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org,
	drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>
Resent-Message-ID: <20160510091243.GB16459@soda.linbit>
In-Reply-To: <20160509131547.GX16459-w1SgEEioFePxa46PmUWvFg@public.gmane.org>
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

Le 09/05/2016 15:15, Lars Ellenberg a =E9crit :
> On Mon, May 09, 2016 at 11:40:20AM +0200, Nicolas Dichtel wrote:
[snip]
>> Maybe prefixing genl_magic_func.h and genl_magic_struct.h by 'drbd_'
>> could be interesting so that new module won't use it. What is your
>> opinion?
> =

> This was supposed to not be DRBD specific.  But it might even still
> need some massaging before it was truly generic. And obviously,
> it does not meet the taste of genetlink folks, to say the least :(
Yes, this file is not generic and netlink APIs are never defined like this.
These tons of macro complexifies the code too much. It's overengineering for
what purpose?
Small examples:
 - the drbd netlink API is not exported via uapi (I wonder how apps using t=
his
   API get it)
 - v2 of the patch is nacked because adding a new attribute may break exist=
ing
   apps (in networking code, a lot of new attributes are added in each vers=
ion)
 - it's not possible to grep to show the definition of an attribute ('git g=
rep
   -w T_bits_total' returns only 1 line)


Regards,
Nicolas
