From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH net-next v6 04/11] landlock: Add LSM hooks related to filesystem
Date: Tue, 18 Apr 2017 16:40:34 -0700
Message-ID: <CAGXu5jKCr1qPqJ8YWAjK1Lj-fThAhMnrxFW8twFcj6C9ODBpsA@mail.gmail.com>
References: <20170328234650.19695-1-mic@digikod.net> <20170328234650.19695-5-mic@digikod.net>
 <CAGXu5jJKNp8R5kZ1U=K7KwgnV=NvH5aoAbftA-05a_Sa4pOg1Q@mail.gmail.com>
 <9a69055a-b4cf-00b0-da5e-2e45ff88059c@digikod.net> <c122415d-c2be-d013-efb4-833ba87d144d@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
        LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Jann Horn <jann@thejh.net>, Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>,
        Shuah Khan <shuah@kernel.org>, Tejun Heo <tj@kernel.org>,
        Thomas Graf <tgraf@suug.ch>, W
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:36816 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758371AbdDRXkg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 19:40:36 -0400
Received: by mail-it0-f53.google.com with SMTP id b15so19775797iti.1
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 16:40:35 -0700 (PDT)
In-Reply-To: <c122415d-c2be-d013-efb4-833ba87d144d@schaufler-ca.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 18, 2017 at 4:16 PM, Casey Schaufler <casey@schaufler-ca.com> w=
rote:
> On 4/18/2017 3:44 PM, Micka=C3=ABl Sala=C3=BCn wrote:
>> On 19/04/2017 00:17, Kees Cook wrote:
>>> On Tue, Mar 28, 2017 at 4:46 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>>>> +void __init landlock_add_hooks(void)
>>>> +{
>>>> +       pr_info("landlock: Version %u", LANDLOCK_VERSION);
>>>> +       landlock_add_hooks_fs();
>>>> +       security_add_hooks(NULL, 0, "landlock");
>>>> +       bpf_register_prog_type(&bpf_landlock_type);
>>> I'm confused by the separation of hook registration here. The call to
>>> security_add_hooks is with count=3D0 is especially weird. Why isn't thi=
s
>>> just a single call with security_add_hooks(landlock_hooks,
>>> ARRAY_SIZE(landlock_hooks), "landlock")?
>> Yes, this is ugly with the new security_add_hooks() with three arguments
>> but I wanted to split the hooks definition in multiple files.
>
> Why? I'll buy a good argument, but there are dangers in
> allowing multiple calls to security_add_hooks().
>
>>
>> The current security_add_hooks() use lsm_append(lsm, &lsm_names) which
>> is not exported. Unfortunately, calling multiple security_add_hooks()
>> with the same LSM name would register multiple names for the same LSM=E2=
=80=A6
>> Is it OK if I modify this function to not add duplicated entries?
>
> It may seem absurd, but it's conceivable that a module might
> have two hooks it wants called. My example is a module that
> counts the number of times SELinux denies a process access to
> things (which needs to be called before and after SELinux in
> order to detect denials) and takes "appropriate action" if
> too many denials occur. It would be weird, wonky and hackish,
> but that never stopped anybody before.

If ends up being sane and clear, I'm fine with allowing multiple calls.

-Kees

--=20
Kees Cook
Pixel Security
