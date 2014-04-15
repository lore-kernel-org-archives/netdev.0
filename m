From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing cgroup path
Date: Tue, 15 Apr 2014 14:53:13 -0700
Message-ID: <CALCETrURHNmLyccRiF_W8o2ozRMR4AaCjUE=_PU8z1+Pq6X2jQ@mail.gmail.com>
References: <1397596546-10153-1-git-send-email-vgoyal@redhat.com> <1397596546-10153-3-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1397596546-10153-3-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 15, 2014 at 2:15 PM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> This patch implements socket option SO_PASSCGROUP along the lines of
> SO_PASSCRED.
>
> If SO_PASSCGROUP is set, then recvmsg() will get a control message
> SCM_CGROUP which will contain the cgroup path of sender. This cgroup
> belongs to first mounted hierarchy in the sytem.
>
> SCM_CGROUP control message can only be received and sender can not send
> a SCM_CGROUP message. Kernel automatically generates one if receiver
> chooses to receive one.
>
> This works both for unix stream and datagram sockets.
>
> cgroup information is passed only if either the sender or receiver has
> SO_PASSCGROUP option set. This means for existing workloads they should
> not see any significant performance impact of this change.

This is odd.  Shouldn't an SCM_CGROUP cmsg be generated when the
receiver has SO_PASSCGROUP set and the sender passes SCM_CGROUP to
sendmsg?

--Andy
