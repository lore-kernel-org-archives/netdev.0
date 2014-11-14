From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next 1/7] bpf: add 'flags' attribute to
 BPF_MAP_UPDATE_ELEM command
Date: Fri, 14 Nov 2014 08:31:27 -0800
Message-ID: <CAMEtUuwH2U-GhBLTJQUV3=cTuZpkpHvrRQtOza8zDENR=D9Yig@mail.gmail.com>
References: <1415929010-9361-1-git-send-email-ast@plumgrid.com>
	<1415929010-9361-2-git-send-email-ast@plumgrid.com>
	<1415967071.15154.9.camel@localhost>
	<CAMEtUux2vuN3iNaAsxybyFwzfMRVe1+BOW-JvnvYYh+=-vpELw@mail.gmail.com>
	<1415981203.15154.45.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415981203.15154.45.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 14, 2014 at 8:06 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Fr, 2014-11-14 at 07:33 -0800, Alexei Starovoitov wrote:
>> On Fri, Nov 14, 2014 at 4:11 AM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>> > On Do, 2014-11-13 at 17:36 -0800, Alexei Starovoitov wrote:
>> >> the current meaning of BPF_MAP_UPDATE_ELEM syscall command is:
>> >> either update existing map element or create a new one.
>> >> Initially the plan was to add a new command to handle the case of
>> >> 'create new element if it didn't exist', but 'flags' style looks
>> >> cleaner and overall diff is much smaller (more code reused), so add 'flags'
>> >> attribute to BPF_MAP_UPDATE_ELEM command with the following meaning:
>> >>  #define BPF_ANY      0 /* create new element or update existing */
>> >>  #define BPF_NOEXIST  1 /* create new element if it didn't exist */
>> >>  #define BPF_EXIST    2 /* update existing element */
>> >
>> > Would a cmpxchg-alike function be handy here?
>>
>> you mean cmpxchg command in addition to
>> update() command ?
>> May be... it will have an extra 'value' argument
>> (key, old_value, new_value)
>> I don't have a use case for it yet though.
>
> I don't neither. ;)
>
> I just wanted to bring this up before user space api might get public
> and the additional argument might make problems.

addition of cmpxchg command won't be a problem obviously.
(just another 'new_value' field in existing struct inside bpf_attr union).
