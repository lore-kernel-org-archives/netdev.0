From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] compat bug in sys_recvmsg, MSG_CMSG_COMPAT check
 missing
Date: Sat, 5 Jun 2004 14:01:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040605140153.6c5945a0.davem@redhat.com>
References: <20040605204334.GA1134@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Hering <olh@suse.de>
In-Reply-To: <20040605204334.GA1134@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 5 Jun 2004 22:43:34 +0200
Olaf Hering <olh@suse.de> wrote:

> packet_recvmsg() gets the flags from the compat_sys_socketcall(), but it
> does not check for the active MSG_CMSG_COMPAT bit. As a result, it
> returns -EINVAL and makes the user rather unhappy

Not just packet_recvmsg() (frankly, I'm stumped how tcpdump is working
on my sparc64 boxes due to this bug!), every other sendmsg/recvmsg
implementation has a test like this verifying the msg_flags for bogons.

Let's ask a better question, why do we need to pass this thing down
into the implementations anyways?

I can't see a reason, can anyone else?  If there is no reason, the
right fix is simply to mask it out at the top level, for both
sendmsg and recvmsg.
