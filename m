From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Fri, 16 Oct 2015 10:32:04 -0700
Message-ID: <56213494.9070504@plumgrid.com>
References: <cover.1444956943.git.daniel@iogearbox.net>
 <ab1fceb2d68876d89bb2ebb3d2b45486d3cf2388.1444956943.git.daniel@iogearbox.net>
 <1444991103.2861759.411876897.42C807BD@webmail.messagingengine.com>
 <56212366.4000307@plumgrid.com>
 <1445013831.2945152.412200185.4C763002@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, ebiederm@xmission.com, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445013831.2945152.412200185.4C763002@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/16/15 9:43 AM, Hannes Frederic Sowa wrote:
> Hi Alexei,
>
> On Fri, Oct 16, 2015, at 18:18, Alexei Starovoitov wrote:
>> On 10/16/15 3:25 AM, Hannes Frederic Sowa wrote:
>>> Namespaces at some point dealt with the same problem, they nowadays use
>>> bind mounts of/proc/$$/ns/* to some place in the file hierarchy to keep
>>> the namespace alive. This at least allows someone to build up its own
>>> hierarchy with normal unix tools and not hidden inside a C-program. For
>>> filedescriptors we already have/proc/$$/fd/* but it seems that doesn't
>>> work out of the box nowadays.
>>
>> bind mounting of /proc/../fd was initially proposed by Andy and we've
>> looked at it thoroughly, but after discussion with Eric it became
>> apparent that it doesn't fit here. At the end we need shell tools
>> to access maps.
>
> Oh yes, I want shell tools for this very much! Maybe even that things
> like strings, grep etc. work. :)

yes and the only way to get there is to have it done via fs.

>> Also I think you missed the hierarchy in this patch set _is_ built with
>> normal 'mkdir' and files are removed with 'rm'.
>
> I did not miss that, I am just concerned that if the kernel does not
> enforce such a hierarchy automatically it won't really happen.

if it's easier for user to work with single level of directories,
it should be able to do so. It's not a job of the kernel to enforce
how user space apps should be designed.

> Oh, tracing does not allow daemons. Why? I can only imagine embedded
> users, no?

yes and for networking: restartability and HA.
cannot really do that with fuse/daemons.
