From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Thu, 26 Jan 2017 09:46:32 -0800
Message-ID: <588A35F8.6050909@fb.com>
References: <1485401274-2836524-1-git-send-email-ast@fb.com>
 <87efzq8jbi.fsf@xmission.com> <588995DE.9040707@fb.com>
 <CALCETrXQ8JFV28xU7tnh3tVbe_mp5yOtHp6shi10GMNnVCQowg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
        Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>,
        Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:46812 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753883AbdAZRrv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 12:47:51 -0500
In-Reply-To: <CALCETrXQ8JFV28xU7tnh3tVbe_mp5yOtHp6shi10GMNnVCQowg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/26/17 8:37 AM, Andy Lutomirski wrote:
>> Think of bpf programs as safe kernel modules. They don't have
>> confined boundaries and program authors, if not careful, can shoot
>> themselves in the foot. We're not trying to prevent that because
>> it's impossible to check that the program is sane. Just like
>> it's impossible to check that kernel module is sane.
>> But in case of bpf we check that bpf program is _safe_ from the kernel
>> point of view. If it's doing some garbage, it's program's business.
>> Does it make more sense now?
>>
>
> With all due respect, I think this is not an acceptable way to think
> about BPF at all.  If you think of BPF this way, I think there needs
> to be a real discussion at KS or similar as to whether this is okay.
> The reason is simple: the kernel promises a stable ABI to userspace
> but not to kernel modules.  By thinking of BPF as more like a module,
> you're taking a big shortcut that will either result in ABI breakage
> down the road or in committing to a problematic stable ABI.

you misunderstood the analogy.
bpf abi is certainly stable. that's why we were careful of not
exposing anything to it that is not already stable.
