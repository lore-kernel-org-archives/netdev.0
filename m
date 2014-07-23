From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC v2 net-next 07/16] bpf: add lookup/update/delete/iterate
 methods to BPF maps
Date: Wed, 23 Jul 2014 14:22:24 -0700
Message-ID: <CAMEtUuy6DsrTF1ejA64nfYvBUJ2mUb4M=sjkVAwswf4Ot=P7Gw@mail.gmail.com>
References: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
	<1405657206-12060-8-git-send-email-ast@plumgrid.com>
	<CAGXu5j+cvG5BhNSA=UrcbYs3LPSZUZyj4_ey8=9O0KgbUYUd9g@mail.gmail.com>
	<CAMEtUuwE1oLUZb2QM243uKGSAfT_ahozducakpi9uvADzsj5XA@mail.gmail.com>
	<CAGXu5jKA9gArKaqODsD0kswmP0Q77w152VXhq9zCS4pgTZf+Jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:56785 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933568AbaGWVW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 17:22:26 -0400
Received: by mail-wg0-f50.google.com with SMTP id n12so1784103wgh.33
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 14:22:24 -0700 (PDT)
In-Reply-To: <CAGXu5jKA9gArKaqODsD0kswmP0Q77w152VXhq9zCS4pgTZf+Jg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 23, 2014 at 1:25 PM, Kees Cook <keescook@chromium.org> wrote:
> On Wed, Jul 23, 2014 at 12:49 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> On Wed, Jul 23, 2014 at 11:25 AM, Kees Cook <keescook@chromium.org> wrote:
>>>> +
>>>> +       /* lookup key in a given map referenced by map_id
>>>> +        * err = bpf_map_lookup_elem(int map_id, void *key, void *value)
>>>
>>> This needs map_id documentation updates too?
>>
>> yes. will grep for it just to make sure.
>>
>>>> +static int get_map_id(struct fd f)
>>>> +{
>>>> +       struct bpf_map *map;
>>>> +
>>>> +       if (!f.file)
>>>> +               return -EBADF;
>>>> +
>>>> +       if (f.file->f_op != &bpf_map_fops) {
>>>> +               fdput(f);
>>>
>>> It feels weird to me to do the fdput inside this function. Instead,
>>> should map_lookup_elem get a "err_put" label, instead?
>>
>> I don't think it will work, since I'm not sure that fd.flags will be zero
>> when fd.file == NULL. It looks so by analyzing return code path
>> in fs/file.c, but I wasn't sure that I followed all code paths,
>> so I just picked this style from fs/timerfd.c assuming it was
>> done this away on purpose and there can be the case where
>> fd.file == null and fd.flags !=0. In such case we cannot call fdput().
>
> Yeah, hm, looking around, this does seem to be the case. I guess the
> thought is that when get_map_id fails, struct fd has been handled.

correct.

> Maybe add a comment above that function as a reminder?

yes. will do.
