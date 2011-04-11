From: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: nfs client doesn't work [was: mmotm 2011-03-31-14-48 uploaded]
Date: Mon, 11 Apr 2011 22:40:56 +0200
Message-ID: <4DA36758.4070203@suse.cz>
References: <201103312224.p2VMOA5g000983@imap1.linux-foundation.org> <4D96E4C5.2080302@suse.cz> <1302122693.16786.0.camel@lade.trondhjem.org> <4D9D5CC9.2040002@suse.cz> <4DA36722.2020402@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Myklebust, Trond" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	mm-commits-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ML netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: bjschuma-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4DA36722.2020402-AlSwsSmVLrQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ccing Bryan

On 04/11/2011 10:40 PM, Jiri Slaby wrote:
> On 04/07/2011 08:42 AM, Jiri Slaby wrote:
>> On 04/06/2011 10:44 PM, Myklebust, Trond wrote:
>>> On Sat, 2011-04-02 at 10:56 +0200, Jiri Slaby wrote:
>>>> On 03/31/2011 11:48 PM, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org wrote:
>>>>> The mm-of-the-moment snapshot 2011-03-31-14-48 has been uploaded to
>>>>
>>>> Hi, nfs client is defunct in this kernel. Tcpdump says:
>>>> 10:51:55.489717 IP 10.20.11.33.759945860 > 10.20.3.2.2049: 132 getattr
>>>> fh 0,0/24
>>>> 10:51:55.515927 IP 10.20.3.2.2049 > 10.20.11.33.759945860: reply ok 44
>>>> getattr ERROR: Operation not permitted
>>>> 10:51:55.515949 IP 10.20.11.33.921 > 10.20.3.2.2049: Flags [.], ack
>>>> 3569361440, win 115, options [nop,nop,TS val 599750 ecr 255058541],
>>> length 0
>>>> 10:52:04.130310 IP 10.20.11.33.793500292 > 10.20.3.2.2049: 76 getattr fh
>>>> 0,0/24
>>>> 10:52:04.152178 IP 10.20.3.2.2049 > 10.20.11.33.793500292: reply ok 44
>>>> getattr ERROR: Operation not permitted
>>>>
>>>> If I run the same mount command (mount -oro,intr host:dir mountpoint)
>>>> from within a virtual machine with 2.6.38.2 there, everything mounts OK.
>>>
>>> Does the attached patch help?
>>
>> No, still the operation not permitted in the tcpdump output and no mount.
> 
> The next tree from 20110411 still doesn't work. The topmost commit in
> fs/nfs/namespace.c is:
> commit 418875900e3de4831c84f86ae4756690dac5be77
> Author: Bryan Schumaker <bjschuma-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
> Date:   Wed Apr 6 14:33:28 2011 -0400
> 
>     NFS: Fix a signed vs. unsigned secinfo bug
> 
> 
> I bisected it to (in vanilla already):
> 
> 8f70e95f9f4159184f557a1db60c909d7c1bd2e3 is the first bad commit
> commit 8f70e95f9f4159184f557a1db60c909d7c1bd2e3
> Author: Bryan Schumaker <bjschuma-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
> Date:   Thu Mar 24 17:12:31 2011 +0000
> 
>     NFS: Determine initial mount security
> 
>     When sec=<something> is not presented as a mount option,
>     we should attempt to determine what security flavor the
>     server is using.
> 
>     Signed-off-by: Bryan Schumaker <bjschuma-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
> 
> :040000 040000 8e5a640b37e00f0df21e1d9cd9aff160df2d5938
> 0152daa67bc8d12e32cda5f4a036807d2e380392 M      fs
> :040000 040000 f74aa33f8597cb82cd0fd7d90d84e0660b7f5804
> 527bc0ca6975cedc7e684b45dc9961f8aaf1207a M      include
> :040000 040000 87559d2f211ea905343a86c8551b6610dd239891
> 7e4ee0e5eddf12474b6de9e7fdb6218b6165bdb2 M      net
> 
> thanks,


-- 
js
suse labs
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
