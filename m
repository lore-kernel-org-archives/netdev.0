From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v4 0/4] netns: allow to identify peer netns
Date: Fri, 31 Oct 2014 10:48:48 +0100
Message-ID: <54535B00.5090708@6wind.com>
References: <1412257690-31253-1-git-send-email-nicolas.dichtel@6wind.com>	<1414682728-4532-1-git-send-email-nicolas.dichtel@6wind.com> <871tpph03k.fsf@x220.int.ebiederm.org>
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
In-Reply-To: <871tpph03k.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 30/10/2014 19:41, Eric W. Biederman a =C3=A9crit :
> Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org> writes:
>
>> The goal of this serie is to be able to multicast netlink messages w=
ith an
>> attribute that identify a peer netns.
>> This is needed by the userland to interpret some informations contai=
ned in
>> netlink messages (like IFLA_LINK value, but also some other attribut=
es in case
>> of x-netns netdevice (see also
>> http://thread.gmane.org/gmane.linux.network/315933/focus=3D316064 an=
d
>> http://thread.gmane.org/gmane.linux.kernel.containers/28301/focus=3D=
4239)).
>>
>> Ids of peer netns are set by userland via a new genl messages. These=
 ids are
>> stored per netns and are local (ie only valid in the netns where the=
y are set).
>> To avoid allocating an int for each peer netns, I use idr_for_each()=
 to retrieve
>> the id of a peer netns. Note that it will be possible to add a table=
 (struct net
>> -> id) later to optimize this lookup if needed.
>>
>> Patch 1/4 introduces the netlink API mechanism to set and get these =
ids.
>> Patch 2/4 and 3/4 implements an example of how to use these ids in r=
tnetlink
>> messages. And patch 4/4 shows that the netlink messages can be symet=
ric between
>> a GET and a SET.
>>
>> iproute2 patches are available, I can send them on demand.
>
> A quick reply.  I think this patchset is in the right general directi=
on.
> There are some oddball details that seem odd/awkward to me such as us=
ing
> genetlink instead of rtnetlink to get and set the ids, and not having
> ids if they are not set (that feels like a maintenance/usability chal=
lenge).
No problem to use rtnetlink, in fact, I hesitated.

=46or the second point, I'm not sure to follow you: how to have an id, =
which will
not break migration, without asking the user to set it?
Note that if the user does not provide an id, you still have a magic va=
lue to
say "it's a peer netns but we don't know which one".

>
> I would like to give your patches a deep review, but I won't be able =
to
> do that for a couple of weeks.  I am deep in the process of moving,
> and will be mostly offline until about the Nov 11th.

No problem, I will wait.
I would be great to get a final version for the 3.19 ;-)


Thank you,
Nicolas
