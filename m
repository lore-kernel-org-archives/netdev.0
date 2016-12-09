From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: netlink: GPF in sock_sndtimeo
Date: Fri, 9 Dec 2016 12:53:21 +0100
Message-ID: <CACT4Y+ZsOXoQqVE4vhenb9fUJkwAbGL6wUZxGyaT2h7Cncbfog@mail.gmail.com>
References: <20161129164859.GD26673@madcap2.tricolour.ca> <CAM_iQpX_KBEpL1dCBNMgZQ-VQJM9nmsVdRPVK-Aen9k0gV3f0w@mail.gmail.com>
 <20161130045207.GE26673@madcap2.tricolour.ca> <20161209060248.GT22655@madcap2.tricolour.ca>
 <CACT4Y+beWN9jmdTREk3JdEBQ3GRALGDJhy7pYF=wu3HdnNWEog@mail.gmail.com> <20161209114847.GX22655@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Richard Guy Briggs <rgb@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161209114847.GX22655@madcap2.tricolour.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 9, 2016 at 12:48 PM, Richard Guy Briggs <rgb@redhat.com> wrote:
> On 2016-12-09 11:49, Dmitry Vyukov wrote:
>> On Fri, Dec 9, 2016 at 7:02 AM, Richard Guy Briggs <rgb@redhat.com> wrot=
e:
>> > On 2016-11-29 23:52, Richard Guy Briggs wrote:
>> > I tried a quick compile attempt on the test case (I assume it is a
>> > socket fuzzer) and get the following compile error:
>> > cc -g -O0 -Wall -D_GNU_SOURCE -o socket_fuzz socket_fuzz.c
>> > socket_fuzz.c:16:1: warning: "_GNU_SOURCE" redefined
>> > <command-line>: warning: this is the location of the previous definiti=
on
>> > socket_fuzz.c: In function =E2=80=98segv_handler=E2=80=99:
>> > socket_fuzz.c:89: warning: implicit declaration of function =E2=80=98_=
_atomic_load_n=E2=80=99
>> > socket_fuzz.c:89: error: =E2=80=98__ATOMIC_RELAXED=E2=80=99 undeclared=
 (first use in this function)
>> > socket_fuzz.c:89: error: (Each undeclared identifier is reported only =
once
>> > socket_fuzz.c:89: error: for each function it appears in.)
>> > socket_fuzz.c: In function =E2=80=98loop=E2=80=99:
>> > socket_fuzz.c:280: warning: unused variable =E2=80=98errno0=E2=80=99
>> > socket_fuzz.c: In function =E2=80=98test=E2=80=99:
>> > socket_fuzz.c:303: warning: implicit declaration of function =E2=80=98=
__atomic_fetch_add=E2=80=99
>> > socket_fuzz.c:303: error: =E2=80=98__ATOMIC_SEQ_CST=E2=80=99 undeclare=
d (first use in this function)
>> > socket_fuzz.c:303: warning: implicit declaration of function =E2=80=98=
__atomic_fetch_sub=E2=80=99
>>
>> -std=3Dgnu99 should help
>> ignore warnings
>
> I got a little further, left with "__ATOMIC_RELAXED undeclared", "__ATOMI=
C_SEQ_CST
> undeclared" under gcc 4.4.7-16.
>
> gcc 4.8.2-15 leaves me with "undefined reference to `clock_gettime'"

add -lrt


> What compiler version do you recommend?

6.x sounds reasonable
4.4 branch is 7.5 years old, surprised that it does not disintegrate
into dust yet :)


>> >> - RGB
>> >
>> > - RGB
>
> - RGB
>
> --
> Richard Guy Briggs <rgb@redhat.com>
> Kernel Security Engineering, Base Operating Systems, Red Hat
> Remote, Ottawa, Canada
> Voice: +1.647.777.2635, Internal: (81) 32635
