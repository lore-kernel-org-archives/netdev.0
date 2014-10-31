From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v4 1/4] netns: add genl cmd to add and get peer
 netns ids
Date: Fri, 31 Oct 2014 10:41:24 +0100
Message-ID: <54535944.6050405@6wind.com>
References: <1412257690-31253-1-git-send-email-nicolas.dichtel@6wind.com>	<1414682728-4532-1-git-send-email-nicolas.dichtel@6wind.com>	<1414682728-4532-2-git-send-email-nicolas.dichtel@6wind.com> <874mulh0cs.fsf@x220.int.ebiederm.org>
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
In-Reply-To: <874mulh0cs.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 30/10/2014 19:35, Eric W. Biederman a =C3=A9crit :
> Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org> writes:
>
>> With this patch, a user can define an id for a peer netns by providi=
ng a FD or a
>> PID. These ids are local to netns (ie valid only into one netns).
>
> Scratches head.  Do you actually find value in using the pid instead =
of
> a file descriptor?
I copied the mechanism from rtnl_link_get_net():
=46irst check if the user provides a PID, if not, check for a FD.

>
> Doing things by pid was an early attempt to make things work, and has
> been a bit clutsy.  If you don't find value in it I would recommend j=
ust
> supporting getting/setting the network namespace by file descriptor.
Hmm, if I understand well, it's what is done in the patch:

[snip]
>> +static int netns_nl_cmd_newid(struct sk_buff *skb, struct genl_info=
 *info)
>> +{
[snip]
>> +	if (info->attrs[NETNSA_PID])
>> +		peer =3D get_net_ns_by_pid(nla_get_u32(info->attrs[NETNSA_PID]));
>> +	else if (info->attrs[NETNSA_FD])
>> +		peer =3D get_net_ns_by_fd(nla_get_u32(info->attrs[NETNSA_FD]));
>> +	else
>> +		return -EINVAL;
>> +	if (IS_ERR(peer))
>> +		return PTR_ERR(peer);

Am I right?


Regards,
Nicolas
