From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Fri, 16 Oct 2015 10:37:52 -0700
Message-ID: <562135F0.5050401@plumgrid.com>
References: <cover.1444956943.git.daniel@iogearbox.net>
 <ab1fceb2d68876d89bb2ebb3d2b45486d3cf2388.1444956943.git.daniel@iogearbox.net>
 <1444991103.2861759.411876897.42C807BD@webmail.messagingengine.com>
 <5620FD52.2060103@iogearbox.net>
 <1445013408.2943971.412165665.3C995178@webmail.messagingengine.com>
 <5621337D.8090003@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, ebiederm@xmission.com, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5621337D.8090003@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/16/15 10:27 AM, Daniel Borkmann wrote:
>>> but don't know how flexible we are in
>>> terms of adding S_IFBPF to the UAPI.
>>
>> I don't think it should be a problem. You referred to POSIX Standard in
>> your other mail but I can't see any reason why not to establish a new
>> file mode. Anyway, FreeBSD (e.g. whiteouts) and Solaris (e.g. Doors,
>> Event Ports) are just examples of new modes being added.
>>
>> mknod /bpf/map/1 m 1 1
>>
>> :)
>>
>> Yes, maybe I think this is a better solution architectural instead of
>> constructing a new filesystem.
>
> Yeah, also 'man 2 stat' lists a couple of others used by various systems.
>
> The pro's of this approach would be that no new file system would be needed
> and the special inode could be placed on top of any 'regular' file system
> that would support special files. I do like that as well.

I don't like it at all for the reasons you've just stated:
'it will prevent us doing shell style access to such files'

> I'm wondering whether this would prevent us in future from opening access
> to shell tools etc on that special file, but probably one could provide a
> default set of file ops via init_special_inode() that could be overloaded
> by the underlying fs if required.

and also because adding new S_ISSOCK-like bit for bpf feel as a begining
of nightmare, since sooner or later all filesystems would need to have
a check for it like they have for sock type.
