From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 1/2] bpf: do not use KMALLOC_SHIFT_MAX
Date: Sat, 17 Dec 2016 00:40:28 +0100
Message-ID: <58547B6C.6000905@iogearbox.net>
References: <20161215164722.21586-1-mhocko@kernel.org> <20161215164722.21586-2-mhocko@kernel.org> <20161216180209.GA77597@ast-mbp.thefacebook.com> <20161216220235.GD7645@dhcp22.suse.cz> <20161216232340.GA99159@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, Cristopher Lameter <cl@linux.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
 Michal Hocko <mhocko@kernel.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20161216232340.GA99159@ast-mbp.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 12/17/2016 12:23 AM, Alexei Starovoitov wrote:
> On Fri, Dec 16, 2016 at 11:02:35PM +0100, Michal Hocko wrote:
>> On Fri 16-12-16 10:02:10, Alexei Starovoitov wrote:
>>> On Thu, Dec 15, 2016 at 05:47:21PM +0100, Michal Hocko wrote:
>>>> From: Michal Hocko <mhocko@suse.com>
>>>>
>>>> 01b3f52157ff ("bpf: fix allocation warnings in bpf maps and integer
>>>> overflow") has added checks for the maximum allocateable size. It
>>>> (ab)used KMALLOC_SHIFT_MAX for that purpose. While this is not incorrect
>>>> it is not very clean because we already have KMALLOC_MAX_SIZE for this
>>>> very reason so let's change both checks to use KMALLOC_MAX_SIZE instead.
>>>>
>>>> Cc: Alexei Starovoitov <ast@kernel.org>
>>>> Signed-off-by: Michal Hocko <mhocko@suse.com>
>>>
>>> Nack until the patches 1 and 2 are reversed.
>>
>> I do not insist on ordering. The thing is that it shouldn't matter all
>> that much. Or are you worried about bisectability?
>
> This patch 1 strongly depends on patch 2 !
> Therefore order matters.
> The patch 1 by itself is broken.
> The commit log is saying
> '(ab)used KMALLOC_SHIFT_MAX for that purpose .. use KMALLOC_MAX_SIZE instead'
> that is also incorrect. We cannot do that until KMALLOC_MAX_SIZE is fixed.
> So please change the order and fix the commit log to say that KMALLOC_MAX_SIZE
> is actually valid limit now.

Michal, please also Cc netdev on your v2. Looks like the set
originally didn't Cc it (at least I didn't see 2/2). Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
