From: Dmitrijs Ivanovs <dmitrijs.ivanovs-NO1NBkfNQUg@public.gmane.org>
Subject: Re: NETLINK_URELEASE non-bound socket problem (was: [PATCH] Fix local
 DoS in cfg80211 subsystem)
Date: Wed, 6 Apr 2016 11:20:24 +0300
Message-ID: <CAFSVvRcMQx1Vjv=Qwyb525Qq5DzBBD6c=n=-i+pWFFVqHRyAxQ@mail.gmail.com>
References: <CAFSVvRfjZszSfovXZ0piPqOgVKH=10sG7pvnvkoWJChL38ifqQ@mail.gmail.com>
	<1459850188.18188.38.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	samuel <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1459850188.18188.38.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Johannes!

I will prepare patch which does not send NETLINK_URELEASE for unbound
sockets as you suggest. But I think protocol check in nl80211 is still
needed because port_id is unique per-protocol.

On Tue, Apr 5, 2016 at 12:56 PM, Johannes Berg
<johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> Hi Dmitrijs,
>
> Thanks for reporting this problem.
>
>> The patch below corrects this problem in kernel space.
>
> I don't think that this is correct, there are four more users of
> NETLINK_URELEASE (nfnetlink, NFC), and afaict all of them have the same
> bug as nl80211.
>
> Rather than fix all of them, I think we should simply not report
> NETLINK_URELEASE for netlink sockets that weren't bound; if any user
> comes up that requires them later we could add a new event instead.
>
> I can't find what commit introduced this code, it goes back before git
> history, so I don't have the commit log. Maybe it was done for
> nfnetlink log/queue? Certainly both nl80211 and NFC are much newer.
>
>> Also, it is
>> recommended to ensure that user-space applications are not using
>> user-supplied port_id for netlink sockets (which is default in
>> libnl-tiny for example).
>
> This I think we should remove from the commit log - it's misleading and
> there's no point.
>
> johannes
>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
