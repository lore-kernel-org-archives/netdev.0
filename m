From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2009-02-23
Date: Thu, 26 Feb 2009 19:18:49 -0800
Message-ID: <43e72e890902261918p47e45b14i7528dd0f40685879@mail.gmail.com>
References: <20090223192659.GB3553@tuxdriver.com>
	 <1235457113.4455.89.camel@johannes.local>
	 <20090224.235510.30497146.davem@davemloft.net>
	 <1235637360.29050.16.camel@johannes.local>
	 <20090226161340.GA4430@tuxdriver.com>
	 <1235698640.4936.6.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1235698640.4936.6.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 26, 2009 at 5:37 PM, Johannes Berg
<johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> On Thu, 2009-02-26 at 11:13 -0500, John W. Linville wrote:
>
>> > Now I just have to get around to fixing it, it's proving to be har=
der
>> > than I thought, and I don't have much time right now.
>>
>> I suppose I could just drop that one. =C2=A0IIRC there was another p=
atch
>> from you that depended upon that one as well?
>
> Ok, so I looked into this, and it turns out that it's harder to fix t=
han
> I thought. Fixing the genl code to call the pre_dumpit at the right
> place is hard and requires netlink (not genl) changes. I'm not in a
> position to do such changes right now, so I would suggest to revert i=
t,
> and for now take the easy way of restructuring nl80211 to take, in ea=
ch
> operation, the rtnl before any other locks instead of trying to do th=
is
> generically.
>
> Luis, would you be up to that? Basically go from
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_lock(&cfg80211_mtx)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0...
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rtnl_lock()
> =C2=A0 =C2=A0 =C2=A0 =C2=A0...
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rtnl_unlock()
> =C2=A0 =C2=A0 =C2=A0 =C2=A0...
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_unlock(&cfg80211_mtx)
>
> to
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rtnl_lock()
> =C2=A0 =C2=A0 =C2=A0 =C2=A0...
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_lock(&cfg80211_mtx)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0...
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_unlock(&cfg80211_mtx)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0...
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rtnl_unlock()
>
> everywhere.

Sure, I'll give it a shot tomorrow unless someone else gets to it first=
=2E

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
