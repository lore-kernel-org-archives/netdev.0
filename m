From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] PKT_SCHED: Fix cls indev validation
Date: 20 Dec 2004 09:16:55 -0500
Message-ID: <1103552215.1048.333.camel@jzny.localdomain>
References: <20041219203050.GK17998@postel.suug.ch>
	 <41C68CEF.3030803@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41C68CEF.3030803@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-12-20 at 03:27, Patrick McHardy wrote:

> There are lots of places where this is possible, just look
> at all the silly checks in the action code:
> 
>     sprintf(act_name, "%s", (char*)RTA_DATA(kind));
>     if (RTA_PAYLOAD(kind) >= IFNAMSIZ) {
> 

Hehe. I am sure thats a cutnpaste(LinuxWay) from some code in the kernel
probably sch_api.c (or maybe the code it was cutnpasted has been fixed
in the last 3 years ;->).
That needs fixing. Who is sending the patch?

> > Puts the indev validation into its own function to allow
> > parameter validation before any changes are made. Changes
> > the sanity check from >= IFNAMSIZ to > IFNAMSIZ to correctly
> > handle 0 terminated strings and replaces the dangerous sprintf
> > with a memcpy bound to the TLV size. Providing a indev TLV
> > for kernels without CONFIG_NET_CLS_IND support will now lead
> > to EOPPNOTSUPP.
> 
> Why special-case indev ? Neither u32 nor fw make any attempt
> to clean up after errors in their init functions, so instead
> of fixing a single attribute they need to do proper cleanup,
> than we can just continue to validate indev when changing it.
> Returning EOPNOTSUPP makes sense, of course.
> 

Indev is going to die - no need in investing a lot of effort in it.

> I'm also against keeping all those printks when touching the
> code. Its ok when writing new code, but I don't see why this
> code, unlike everything else, needs to report errors in the
> ringbuffer instead of returning meaningful error codes.
> 

Its not that expensive since done on config path. But agree when proper
codes exist its not needed.

cheers,
jamal
