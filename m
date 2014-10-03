From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH net-next v3 1/4] netns: add genl cmd to add and get
 peer netns ids
Date: Fri, 03 Oct 2014 14:22:26 +0200
Message-ID: <542E9502.1040104@6wind.com>
References: <542D5726.8070308@6wind.com>	<1412257690-31253-1-git-send-email-nicolas.dichtel@6wind.com>	<1412257690-31253-2-git-send-email-nicolas.dichtel@6wind.com> <87tx3mmflp.fsf@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org,
	cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87tx3mmflp.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 02/10/2014 21:33, Eric W. Biederman a =C3=A9crit :
> Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org> writes:
>
>> With this patch, a user can define an id for a peer netns by providi=
ng a FD or a
>> PID. These ids are local to netns (ie valid only into one netns).
>>
>> This will be useful for netlink messages when a x-netns interface is
>> dumped.
>
> You have a "id -> struct net *" table but you don't have a
> "struct net * -> id" table which looks like it will impact the
> performance of peernet2id at scale.
It is indirectly stores in 'struct idr'. It can be optimized later, wit=
h a
proper algorithm to find quickly this 'struct net *' (hash table? somet=
hing
else?). A basic algorithm will not be more scalable than the current
idr_for_each().
