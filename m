From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: bpf: use-after-free in array_map_alloc
Date: Sun, 17 Apr 2016 18:45:44 -0400
Message-ID: <57141218.4000103@oracle.com>
References: <5713C0AD.3020102@oracle.com>
 <20160417172943.GA83672@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160417172943.GA83672@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/17/2016 01:29 PM, Alexei Starovoitov wrote:
> On Sun, Apr 17, 2016 at 12:58:21PM -0400, Sasha Levin wrote:
>> > Hi all,
>> > 
>> > I've hit the following while fuzzing with syzkaller inside a KVM tools guest
>> > running the latest -next kernel:
> thanks for the report. Adding Tejun...
> if I read the report correctly it's not about bpf, but rather points to
> the issue inside percpu logic.
> First __alloc_percpu_gfp() is called, then the memory is freed with
> free_percpu() which triggers async pcpu_balance_work and then
> pcpu_extend_area_map is hitting use-after-free.
> I guess bpf percpu array map is stressing this logic the most.
> Any simpler steps to reproduce ?

No simple way to reproduce. I blamed bpf because I saw a few traces
and it was only bpf that was causing it, there was no other reasoning
behind it.


Thanks,
Sasha
