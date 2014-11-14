From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v2 net-next 1/7] bpf: add 'flags' attribute to
 BPF_MAP_UPDATE_ELEM command
Date: Fri, 14 Nov 2014 07:33:00 -0800
Message-ID: <CAMEtUux2vuN3iNaAsxybyFwzfMRVe1+BOW-JvnvYYh+=-vpELw@mail.gmail.com>
References: <1415929010-9361-1-git-send-email-ast@plumgrid.com>
	<1415929010-9361-2-git-send-email-ast@plumgrid.com>
	<1415967071.15154.9.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1415967071.15154.9.camel@localhost>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 14, 2014 at 4:11 AM, Hannes Frederic Sowa
<hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org> wrote:
> On Do, 2014-11-13 at 17:36 -0800, Alexei Starovoitov wrote:
>> the current meaning of BPF_MAP_UPDATE_ELEM syscall command is:
>> either update existing map element or create a new one.
>> Initially the plan was to add a new command to handle the case of
>> 'create new element if it didn't exist', but 'flags' style looks
>> cleaner and overall diff is much smaller (more code reused), so add 'flags'
>> attribute to BPF_MAP_UPDATE_ELEM command with the following meaning:
>>  #define BPF_ANY      0 /* create new element or update existing */
>>  #define BPF_NOEXIST  1 /* create new element if it didn't exist */
>>  #define BPF_EXIST    2 /* update existing element */
>
> Would a cmpxchg-alike function be handy here?

you mean cmpxchg command in addition to
update() command ?
May be... it will have an extra 'value' argument
(key, old_value, new_value)
I don't have a use case for it yet though.
