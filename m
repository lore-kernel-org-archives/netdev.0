From: Sam Leffler <sam@errno.com>
Subject: Re: [RFC] Extend netlink error codes
Date: Sat, 11 Sep 2004 11:48:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3A0D075D-0423-11D9-BBE1-000A95AD0668@errno.com>
References: <20040910225158.GO20088@postel.suug.ch> <20040911155839.GN4431@wotan.suse.de> <20040911162433.GC21181@postel.suug.ch>
Mime-Version: 1.0 (Apple Message framework v619)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040911162433.GC21181@postel.suug.ch>
To: Thomas Graf <tgraf@suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sep 11, 2004, at 9:24 AM, Thomas Graf wrote:

> * Andi Kleen <20040911155839.GN4431@wotan.suse.de> 2004-09-11 17:58
>> IMHO it would be far better to just pass text errors
>> in a variable length packet back.  It's a bit plan9ish,
>> but it would work nicely here and be a bit improvement
>> (especially for the qdiscs)
>
> I had the same idea and the only good way to do so would
> be to add a char * errbuf or alike to struct netlink_opt
> and access it via skb.sk.sk_protinfo.
>
> The bad side is that the for example cls and sch api don't
> provide the skb to the implementing modules and therefore
> they can't access the error buffer. I don't want to change
> all netlink users because of this.
>
> Changing all paths back to netlink_ack to provide a struct
> containing the errno and an additional text error buffer is
> no option for me either.
>
> Correct me if I'm wrong.
>
>> Otherwise you will end up with a mainteance nightmare of a
>> long list of error codes that needs to be updated for every new
>> subsystem.
>
> I would suggst to split them up and assign blocks of free codes
> to subsystems.
>
>> And everybody who has a patch to add a new netlink
>> user would always fight with conflicts in this file.
>
> This is indeed a problem.
>
>> I don't think an very specific error like
>> "CFQ subsystem parameter X is FOO, can be only upto BAR"
>> can be nicely put into a global error file.
>
> True, I would really like to have such error messages.

A technique used for mbuf packet tags in FreeBSD is to define a 32-bit 
cookie that uniquely identifies a module or ABI code and concatenate 
this with the 16-bit tag number.  The ABI code is defined as the 
date+time that the module is created, expressed as the number of 
seconds since the epoch (e.g. the output of date -u +'%s').  Tag 
numbers are meaningful only within the context of the module/ABI.  A 
default/compatibility cookie is used for compatibility with previously 
defined tag values.  This scheme effectively distributes management of 
tags (so far there have been no collisions).

Check the comments in sys/sys/mbuf.h on FreeBSD for more details.

	Sam
