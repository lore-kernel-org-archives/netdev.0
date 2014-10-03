From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH net-next v2 0/5] netns: allow to identify peer netns
Date: Fri, 03 Oct 2014 14:22:23 +0200
Message-ID: <542E94FF.7070109@6wind.com>
References: <1411478430-4989-1-git-send-email-nicolas.dichtel@6wind.com>	<87ppei45ig.fsf@x220.int.ebiederm.org>	<CALCETrX5e0cp4QFCv1eAqR1hjoROU9Rh=cRos9U35DaR-py3Eg@mail.gmail.com>	<87y4t61a6v.fsf@x220.int.ebiederm.org> <54294B4E.70501@6wind.com>	<87y4t2gtd0.fsf@x220.int.ebiederm.org> <542D5726.8070308@6wind.com> <8761g2nurx.fsf@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Cong Wang <cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <8761g2nurx.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 02/10/2014 21:20, Eric W. Biederman a =C3=A9crit :
> Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org> writes:
>
>> Le 29/09/2014 20:43, Eric W. Biederman a =C3=A9crit :
>>> Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org> writes:
>>>
>>>> Le 26/09/2014 20:57, Eric W. Biederman a =C3=A9crit :
>>>>> Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:
>>>>>
>>>>>> On Fri, Sep 26, 2014 at 11:10 AM, Eric W. Biederman
>>>>>> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>>>>>> I see two ways to go with this.
>>>>>>>
>>>>>>> - A per network namespace table to that you can store ids for `=
`peer''
>>>>>>>      network namespaces.  The table would need to be populated =
manually by
>>>>>>>      the likes of ip netns add.
>>>>>>>
>>>>>>>      That flips the order of assignment and makes this idea sol=
id.
>>>> I have a preference for this solution, because it allows to have a=
 full
>>>> broadcast messages. When you have a lot of network interfaces (> 1=
0k),
>>>> it saves a lot of time to avoid another request to get all informa=
tions.
>>>
>>> My practical question is how often does it happen that we care?
>> In fact, I don't think that scenarii with a lot of netns have a full=
 mesh of
>> x-netns interfaces. It will be more one "link" netns with the physic=
al
>> interface and all other with one interface with the link part in thi=
s "link"
>> netns. Hence, only one nsid is needing in each netns.
>
> I will buy that a full mesh is unlikely.
>
> For people doing simulations anything physical has a limited number o=
f
> links.
>
> For people wanting all to all connectivity setting up an internal
> macvlan (or the equivalent) is likely much simpler and more efficient
> that a full mesh.
>
> So the question in my mind is how do we create these identifiers at n=
eed
> (when we create the cross network namespace links) instead of at netw=
ork
> namespace creation time.  I don't see an answer to that in your patch=
es,
> and perhaps it obvious.
=46or me, it is the responsability of the user who creates the netns. H=
e should
know what will be done with this new netns, hence he may or may not def=
ine an
id. It's also possible to delegate this to the user who will create the=
 tunnel.
In other words, it's part of the configuration.
