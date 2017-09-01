From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RESEND PATCH] Allow passing tid or pid in SCM_CREDENTIALS without CAP_SYS_ADMIN
Date: Fri, 01 Sep 2017 14:29:09 -0500
Message-ID: <878thyw73u.fsf@xmission.com>
References: <1503965540-30393-1-git-send-email-prakash.sangappa@oracle.com>
        <20170829.160232.1901318933754673000.davem@davemloft.net>
        <c9ea9bec-6b0e-70d6-3f74-9b483358edd2@oracle.com>
        <87ziahzzhx.fsf@xmission.com>
        <d23ec1ae-e2f0-659c-ce67-9b1b1e9ad8a5@oracle.com>
        <87inh5ymv2.fsf@xmission.com>
        <ca086e10-764c-4389-808e-43fd1ace4e0c@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, drepper@redhat.com
To: Prakash Sangappa <prakash.sangappa@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ca086e10-764c-4389-808e-43fd1ace4e0c@oracle.com> (Prakash
        Sangappa's message of "Fri, 1 Sep 2017 10:30:31 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prakash Sangappa <prakash.sangappa@oracle.com> writes:

> On 8/30/17 10:41 AM, ebiederm@xmission.com wrote:
>> Prakash Sangappa <prakash.sangappa@oracle.com> writes:
>>
>>
>>> With regards to security, the question basically is what is the consequence
>>> of passing the wrong id. As I understand it, Interpreting the id to be pid
>>> or tid, the effective uid and gid will be the same. It would be a problem
>>> only if the incorrect interpretation of the id would refer a different process.
>>> But that cannot happen as the the global tid(gettid() of a thread is
>>> unique.
>> There is also the issue that the receiving process could look, not see
>> the pid in proc and assume the sending process is dead.  That I suspect
>> is the larger danger.
>>
>
> Will this not be a bug in the application, if it is sending the wrong
> id?

No.  It could be deliberate and malicious.

>>> As long as the thread is alive, that id cannot reference another process / thread.
>>> Unless the thread were to exit and the id gets recycled and got used for another
>>> thread or process. This would be no different from a process exiting and its
>>> pid getting recycled which is the case now.
>> Largely I agree.
>>
>> If all you want are pid translations I suspect the are far easier ways
>> thant updating the SCM_CREDENTIALS code.
>
> What would be an another easier & efficient way of doing pid translation?
>
> Should a new API/mechanism be considered mainly for pid translation purpose
> for use with pid namespaces, say based on 'pipe' something similar to
> I_SENDFD?

There are proc files that provide all of the pids of a process you can
read those.

Other possibilities exist if you want to go that fast.

Eric
