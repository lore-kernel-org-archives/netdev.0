From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH -next] x86, fs: add sys_compat_write for net/socket.c
Date: Tue, 30 Mar 2010 10:56:05 -0700
Message-ID: <4BB23B35.7060401@zytor.com>
References: <1269971469-1254-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, x86@kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1269971469-1254-1-git-send-email-fw@strlen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/30/2010 10:51 AM, Florian Westphal wrote:
> On some configurations, e.g. x86_64 with 32bit userspace, netlink/xfrm
> misinterprets messages from userspace due to different structure
> layout (u64 has different alignment requirements on x86 vs. x86_64).
> 
> As long as messages are sent via sendmsg(), this could be handled via
> net/compat.c; it will set the CMSG_MSG_COMPAT flag in struct msghdr
> for compat tasks, which would allow to the xfrm_user code to detect
> when messages need compat fixups.
> 
> Unfortunately, some programs (e.g. pluto ike daemon), send netlink data
> to the kernel using write().
> 
> Thus, introduce f_ops->compat_aio_write and compat_sys_write to treat
> writes on sockets specially.
> 
> This only wires up compat_sys_write for x86/x86_64 -- at the moment this
> is only required to parse xfrm netlink messages, which happen to only
> need special treatment in case of COMPAT_FOR_U64_ALIGNMENT=y.
> 
> Setting CMSG_MSG_COMPAT depending on plain is_compat_task() in net/socket.c
> was not done due to concerns regarding the kernel doing socket
> writes in response to a user event (which might set MSG_COMPAT erronously).
> 

OK... I have to ask the question:

This only applies if you're using unpacked structures with
non-naturally-aligned objects in them.  Where to we have those, and can
we shoot the authors?

	-hpa
