From: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Subject: Re: software iwarp stack update
Date: Wed, 15 Jun 2011 20:57:38 +0200
Message-ID: <BANLkTimEGgKEMZd3qppOofN-Vj-u-PH-xA@mail.gmail.com>
References: <BANLkTikUWpf4iAQT-9DwL_qSCEcY7CPN6w@mail.gmail.com> <OFC721DC15.CBE893E3-ONC12578B0.0053737C-C12578B0.00565784@ch.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <OFC721DC15.CBE893E3-ONC12578B0.0053737C-C12578B0.00565784-Xeyd2O9EBijQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 15, 2011 at 5:43 PM, Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org> wrote:
> after rebasing to davem/net-next-2.6.git, I formatted a patch adding
> to the initial 'siw' driver posting from last October. Given the rather
> substantial amount of changes and time elapsed, I am not sure if people
> would better like a complete re-posting of all files.
> If I don't hear objection before tomorrow I would post it as an
> increment - as summarized below.

Documentation in general and for sysfs attributes in particular seems
to be missing ?

Also, the following statement in siw_main.c:

ibdev->modify_port = NULL;

causes the following behavior if ib_modify_port() is invoked on a
softiwarp port:

BUG: unable to handle kernel NULL pointer dereference at           (null)
IP: [<          (null)>]           (null)
Call Trace:
 [<ffffffffa0313c15>] ? ib_modify_port+0x55/0x60 [ib_core]
[ ... ]

Shouldn't the siw driver return an error code instead of setting
ibdev->modify_port to NULL ?

Bart.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
