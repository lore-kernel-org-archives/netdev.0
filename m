From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v1] samples/bpf: Add a .gitignore for binaries
Date: Tue, 16 May 2017 16:27:36 -0700
Message-ID: <ad02fd5c-6812-8f1b-b348-b2ec81b9524b@gmail.com>
References: <20170212212356.11675-1-mic@digikod.net>
 <8277c7cc-8f44-40ec-1f7e-53c404d84292@cumulusnetworks.com>
 <bd91cc8d-4683-4c4c-e672-7dce5da28183@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org
To: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <bd91cc8d-4683-4c4c-e672-7dce5da28183@digikod.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/13/17 3:30 AM, Mickaël Salaün wrote:
> 
> On 13/02/2017 02:43, David Ahern wrote:
>> On 2/12/17 2:23 PM, Mickaël Salaün wrote:
>>> diff --git a/samples/bpf/.gitignore b/samples/bpf/.gitignore
>>> new file mode 100644
>>> index 000000000000..a7562a5ef4c2
>>> --- /dev/null
>>> +++ b/samples/bpf/.gitignore
>>> @@ -0,0 +1,32 @@
>>> +fds_example
>>> +lathist
>>
>> ...
>>
>> Listing each target is going to be a PITA to maintain. It would be
>> better to put targets into a build directory (bin?) and ignore the
>> directory.
>>
> 
> It would require a lot of modifications to the Makefile and more
> complexity. It seems much more simple for everyone to stick to a simple
> gitignore file easily maintainable:
> $ awk '$1 == "hostprogs-y" { print $3 }' < Makefile > .gitignore
> 
> Alexei, Daniel, what do you think about this? Do you want me to send a
> v2 with the new tests?
> 

The problem stems from the fact that bpf samples do not really fall into
the 'hostprogs' category (see "4 Host Program support" in
Documentation/kbuild/makefiles.txt). Fixing samples/bpf to not rely on
it is the better long term solution. Building of tools/ for example does
not rely on it so there is an existing example of leveraging kernel
headers without the overhead.
