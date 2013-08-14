From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v3 00/11] Add namespace support for syslog
Date: Wed, 14 Aug 2013 12:21:47 -0700
Message-ID: <87a9kkcc38.fsf@xmission.com>
References: <1375861035-24320-1-git-send-email-rui.xiang@huawei.com>
	<878v0evssv.fsf@xmission.com> <5202F65F.40002@cn.fujitsu.com>
	<52037D50.2050109@huawei.com> <20130814153017.GA18403@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	libo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	guz.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130814153017.GA18403-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Wed, 14 Aug 2013 15:30:17 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Rui Xiang (rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org):
>> On 2013/8/8 9:37, Gao feng wrote:
>> > On 08/07/2013 03:55 PM, Eric W. Biederman wrote:
>> >>
>> >> Since this still has not been addressed.  I am going to repeat Andrews
>> >> objection again.
>> >>
>> >> Isn't there a better way to get iptables information out than to use
>> >> syslog.  I did not have time to follow up on that but it did appear that
>> >> someone did have a better way to get the information out.
>> >>
>> >> Essentially the argument against this goes.  The kernel logging facility
>> >> is really not a particularly good tool to be using for anything other
>> >> than kernel debugging information, and there appear to be no substantial
>> >> uses for a separate syslog that should not be done in other ways.
>> > 
>> > containerizing syslog is not only for iptables, it also isolates the /dev/kmsg,
>> > /proc/kmsg, syslog(2)... user space tools in container may use this interface
>> > to read/generate syslog.
>> > 
>> > But I don't know how important/urgent this containerizing syslog work is,
>> > Rui Xiang, can you find an important/popular user space tool which uses this
>> > interfaces to generate kernel syslog?
>> > 
>> 
>> There are some other cases. Some warnings (bad mount options for tmpfs,
>> bad uid owner for many of them, etc) emerged in the container should
>> be exported to the container. Some belong on the host - if they show 
>> a corrupt superblock which may indicate an attempt by the container 
>> to crash the kernel. Like these, Kernel will print out warnings when 
>> userspace in container uses a deprecated something or other, and these
>> logs should be invisible and specific for current container.
>> 
>> I can't say this work is terribly compelling and important, but the 
>> impact may be obvious, IMO.
>
> Aug  9 21:49:13 sergeh1 kernel: [4644829.672768] init: Failed to spawn network-interface (veth8Ehlvj) post-stop process: unable to change root directory: No such file ricr:aeohgrticr  cfe rty444984 n:aetswnw-ta(ht -rrsultheoit: hlrro<4865i:i sntkta(ht ttpe btheoit: hlrrob r6ezt)nrgoadgte644915 c0pt(tyg ti wd a
> Aug  9 21:49:13 sergeh1 kernel: X3f d-6:uigitra ora
> Aug  9 22:19:54 sergeh1 kernel: 6[642.175 X3f d-6:mutdflsse ihodrddt oe==99 rfl=lccnanrdfutwt-etn"nm=/a/ah/x/lu-ui/m.AExdu"pi=91 om=mut sye"x3name="/devlo0" lg=r"ol pmc r=3an19pfel-nireu-tntgne/rc/cldudmHEqu d97o=otfy=x"ra=d/o/fg""8b:o vhc)nrgibdte646013 veeMzWe oso d<[4715]xr r1eMc egset
> Aug

That is certainly a mess.  Now I don't believe we allow processes in a
user namespace to write to the kernels log (certainly we shouldn't be)
so part of that is not a problem.

What is interleaving messages into syslog?

And to be clear my only perspective is that we need to make certain we
have this thought out.

Eric
